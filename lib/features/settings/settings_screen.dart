import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers/locale_provider.dart';
import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/services/device_notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../parent/children_list_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationAlerts = true;
  bool _batteryAlerts = true;
  bool _safeZoneAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final settings = await DeviceNotificationService.instance.loadSettings();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = settings.pushEnabled;
      _locationAlerts = settings.locationAlerts;
      _batteryAlerts = settings.batteryAlerts;
      _safeZoneAlerts = settings.safeZoneAlerts;
    });
  }

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

  NotificationSettingsModel get _currentNotificationSettings =>
      NotificationSettingsModel(
        pushEnabled: _notificationsEnabled,
        locationAlerts: _locationAlerts,
        batteryAlerts: _batteryAlerts,
        safeZoneAlerts: _safeZoneAlerts,
      );

  Future<void> _applyNotificationSettings(
    NotificationSettingsModel settings, {
    bool requestPermission = false,
  }) async {
    if (requestPermission && settings.pushEnabled) {
      final granted =
          await DeviceNotificationService.instance.ensurePermissions();
      if (!granted) {
        if (mounted) {
          final t = S.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.notificationPermissionRequired),
            ),
          );
        }
        return;
      }
    }

    await DeviceNotificationService.instance.updateSettings(settings);
    if (settings.pushEnabled) {
      await DeviceNotificationService.instance.refreshNow();
    }

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = settings.pushEnabled;
      _locationAlerts = settings.locationAlerts;
      _batteryAlerts = settings.batteryAlerts;
      _safeZoneAlerts = settings.safeZoneAlerts;
    });
  }

  Future<void> _editProfile() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _EditProfileSheet(),
    );
    if (updated == true && mounted) {
      final t = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.profileUpdated)),
      );
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.settings,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Profile card
          AppCard(
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
                            : 'P',
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
                  user?.displayName ?? user?.username ?? 'Parent',
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
                  text: user?.role == UserRole.parent ? t.parent : t.child,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _editProfile,
                  child: Text(
                    t.editProfileDetails,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Account section
          _SectionTitle(title: t.account),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.people_alt_outlined,
                  iconColor: AppColors.primary,
                  title: t.manageChildrenMenu,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ChildrenListScreen()),
                  ),
                ),
                const Divider(
                    height: 1, indent: 56, color: AppColors.dividerLight),
                _SettingsRow(
                  icon: Icons.person_outline,
                  iconColor: AppColors.primary,
                  title: t.editProfile,
                  onTap: _editProfile,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Notifications section
          _SectionTitle(title: t.notifications),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsSwitchRow(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.warning,
                  title: t.pushNotifications,
                  value: _notificationsEnabled,
                  onChanged: (value) => _applyNotificationSettings(
                    _currentNotificationSettings.copyWith(
                      pushEnabled: value,
                    ),
                    requestPermission: value,
                  ),
                ),
                const Divider(
                    height: 1, indent: 56, color: AppColors.dividerLight),
                _SettingsSwitchRow(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.success,
                  title: t.locationAlerts,
                  value: _locationAlerts,
                  onChanged: (value) => _applyNotificationSettings(
                    _currentNotificationSettings.copyWith(
                      locationAlerts: value,
                    ),
                  ),
                ),
                const Divider(
                    height: 1, indent: 56, color: AppColors.dividerLight),
                _SettingsSwitchRow(
                  icon: Icons.battery_alert_outlined,
                  iconColor: AppColors.danger,
                  title: t.batteryAlerts,
                  value: _batteryAlerts,
                  onChanged: (value) => _applyNotificationSettings(
                    _currentNotificationSettings.copyWith(
                      batteryAlerts: value,
                    ),
                  ),
                ),
                const Divider(
                    height: 1, indent: 56, color: AppColors.dividerLight),
                _SettingsSwitchRow(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.primary,
                  title: t.safeZoneAlerts,
                  value: _safeZoneAlerts,
                  onChanged: (value) => _applyNotificationSettings(
                    _currentNotificationSettings.copyWith(
                      safeZoneAlerts: value,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // General section
          _SectionTitle(title: t.general),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.language,
                  iconColor: AppColors.textSecondaryLight,
                  title: t.language,
                  trailingText: selectedLanguageLabel,
                  onTap: _selectLanguage,
                ),
                const Divider(
                    height: 1, indent: 56, color: AppColors.dividerLight),
                _SettingsRow(
                  icon: Icons.help_outline,
                  iconColor: AppColors.textSecondaryLight,
                  title: t.helpAndSupport,
                  onTap: () {},
                ),
                const Divider(
                    height: 1, indent: 56, color: AppColors.dividerLight),
                _SettingsRow(
                  icon: Icons.info_outline,
                  iconColor: AppColors.textSecondaryLight,
                  title: t.about,
                  onTap: () {},
                ),
                const Divider(
                    height: 1, indent: 56, color: AppColors.dividerLight),
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: AppColors.textSecondaryLight,
                  title: t.privacyPolicy,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(sessionProvider.notifier).logout();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerSoft,
                foregroundColor: AppColors.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(t.signOut,
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
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = S.of(context);
    if (_usernameController.text.trim().isEmpty) {
      setState(() => _error = t.usernameCannotBeEmpty);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(sessionProvider.notifier).updateProfile(
            username: _usernameController.text.trim(),
            displayName: _nameController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.editProfileTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            t.updateProfileHint,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: t.displayName,
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dividerLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dividerLight),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usernameController,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              labelText: t.username,
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dividerLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dividerLight),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    t.saveChanges,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingText,
  });
  final IconData icon;
  final Color iconColor;
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
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
                child: Text(
                  trailingText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.success,
            onChanged: onChanged,
          ),
        ],
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
