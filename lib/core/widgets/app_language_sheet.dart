import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';

Future<void> showAppLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const AppLanguageSheet(),
  );
}

class AppLanguageButton extends ConsumerWidget {
  const AppLanguageButton({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = S.of(context);
    final selectedLocale = ref.watch(appLocaleProvider);
    final selectedLanguageLabel = selectedLocale == null
        ? t.systemDefault
        : languageOptionFor(selectedLocale)?.nativeName ??
            selectedLocale.languageCode.toUpperCase();

    return OutlinedButton.icon(
      onPressed: () => showAppLanguageSheet(context),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        side: const BorderSide(color: AppColors.dividerLight),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: const Icon(Icons.language_rounded, size: 18),
      label: Text(
        compact
            ? selectedLanguageLabel
            : '${t.language}: $selectedLanguageLabel',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class AppLanguageSheet extends ConsumerWidget {
  const AppLanguageSheet({super.key});

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
            _LanguageOptionTile(
              title: t.systemDefault,
              subtitle: null,
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
                  return _LanguageOptionTile(
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

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.title,
    required this.subtitle,
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
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
    );
  }
}
