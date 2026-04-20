import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers/locale_provider.dart';
import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';

/// Kid-friendly settings screen — blue palette with playful rounded shapes.
class ChildSettingsScreen extends ConsumerStatefulWidget {
  const ChildSettingsScreen({super.key});
  @override
  ConsumerState<ChildSettingsScreen> createState() =>
      _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends ConsumerState<ChildSettingsScreen> {
  Future<void> _pickAvatar() async {
    if (kIsWeb) return;
    final picker = ImagePicker();
    final xFile =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (xFile == null) return;
    try {
      final result = await ApiClient.instance.uploadAvatar(File(xFile.path));
      if (!mounted) return;
      final url = result['avatar_url'] as String?;
      if (url != null) {
        ref.read(sessionProvider.notifier).updateAvatar(url);
      }
    } catch (e) {
      if (mounted) {
        final t = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.failedToUploadAvatar(e.toString()))),
        );
      }
    }
  }

  Future<void> _selectLanguage() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _LanguageSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final selectedLocale = ref.watch(appLocaleProvider);
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final selectedLanguageLabel = selectedLocale == null
        ? t.systemDefault
        : languageOptionFor(selectedLocale)?.nativeName ??
            selectedLocale.languageCode.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // Title with kid icon
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care_rounded,
                      color: AppColors.primary, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    t.childSettingsTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            // Profile card — rounded kid style
            _KidCard(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AvatarCircle(
                          initials: (user?.displayName.isNotEmpty ?? false)
                              ? user!.displayName[0].toUpperCase()
                              : 'K',
                          color: AppColors.primary,
                          size: 80,
                          image: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? user?.username ?? 'Kid',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user?.username ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(
                    text: t.child,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // General section
            _KidSectionTitle(title: t.general),
            const SizedBox(height: 8),
            _KidCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _KidSettingsRow(
                    icon: Icons.language_rounded,
                    title: t.language,
                    trailingText: selectedLanguageLabel,
                    onTap: _selectLanguage,
                  ),
                  const Divider(
                      height: 1, indent: 56, color: AppColors.dividerLight),
                  _KidSettingsRow(
                    icon: Icons.help_outline_rounded,
                    title: t.helpAndSupport,
                    onTap: () {},
                  ),
                  const Divider(
                      height: 1, indent: 56, color: AppColors.dividerLight),
                  _KidSettingsRow(
                    icon: Icons.info_outline_rounded,
                    title: t.about,
                    onTap: () {},
                  ),
                  const Divider(
                      height: 1, indent: 56, color: AppColors.dividerLight),
                  _KidSettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    title: t.privacyPolicy,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(sessionProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerSoft,
                  foregroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(t.childLogout,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                t.appVersion,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Kid-themed widgets (blue palette, extra rounded) ────────────────────────

class _KidCard extends StatelessWidget {
  const _KidCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _KidSectionTitle extends StatelessWidget {
  const _KidSectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _KidSettingsRow extends StatelessWidget {
  const _KidSettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          trailingText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textMuted, size: 22),
                    ],
                  ),
                ),
              ),
            ],
            if (trailingText == null)
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = S.of(context);
    final selectedLocale = ref.watch(appLocaleProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.language,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _LanguageTile(
              title: t.systemDefault,
              selected: selectedLocale == null,
              onTap: () async {
                await ref.read(appLocaleProvider.notifier).setLocale(null);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: appLanguageOptions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.dividerLight),
                itemBuilder: (context, index) {
                  final option = appLanguageOptions[index];
                  final selected = selectedLocale != null &&
                      localeMatches(selectedLocale, option.locale);
                  final subtitle = option.englishName == option.nativeName
                      ? null
                      : option.englishName;
                  return _LanguageTile(
                    title: option.nativeName,
                    subtitle: subtitle,
                    selected: selected,
                    onTap: () async {
                      await ref
                          .read(appLocaleProvider.notifier)
                          .setLocale(option.locale);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!,
              style: const TextStyle(color: AppColors.textSecondaryLight)),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
    );
  }
}
