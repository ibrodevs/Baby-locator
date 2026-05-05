import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';
import 'package:kid_security_android_bridge/kid_security_android_bridge.dart';

import '../../core/services/app_blocking_service.dart';
import '../../core/services/device_stats_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/child_theme.dart';
import '../../core/widgets/brand_header.dart';

class AppBlockingScreen extends StatefulWidget {
  const AppBlockingScreen({super.key});

  @override
  State<AppBlockingScreen> createState() => _AppBlockingScreenState();
}

class _AppBlockingScreenState extends State<AppBlockingScreen>
    with WidgetsBindingObserver {
  final AppBlockingService _blockingService = AppBlockingService.instance;
  final DeviceStatsService _deviceStats = const DeviceStatsService();
  final TextEditingController _searchController = TextEditingController();

  List<InstalledAppInfo> _installedApps = const [];
  Set<String> _blockedPackages = const {};
  bool _loading = true;
  bool _saving = false;
  bool? _accessibilityEnabled;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_handleSearchChanged);
    unawaited(_loadData());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPermissions());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    if (!mounted) return;
    setState(() => _query = _searchController.text.trim());
  }

  Future<void> _loadData({bool showLoader = true}) async {
    if (!_blockingService.isSupported) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }

    if (showLoader && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        _blockingService.listInstalledApps(),
        _blockingService.loadBlockedPackages(),
        _blockingService.isAccessibilityServiceEnabled(),
      ]);

      final installedApps =
          (results[0] as List<dynamic>).cast<InstalledAppInfo>().toList();
      final blockedPackages =
          (results[1] as Set<dynamic>).cast<String>().toSet();
      final accessibilityEnabled = results[2] as bool;

      await _blockingService.refreshNativeStateFromPrefs();

      if (!mounted) return;
      setState(() {
        _installedApps = installedApps;
        _blockedPackages = blockedPackages;
        _accessibilityEnabled = accessibilityEnabled;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _refreshPermissions() async {
    if (!_blockingService.isSupported) return;
    try {
      final enabled = await _blockingService.isAccessibilityServiceEnabled();
      await _blockingService.refreshNativeStateFromPrefs();
      if (!mounted) return;
      setState(() => _accessibilityEnabled = enabled);
    } catch (_) {
      // Best effort only.
    }
  }

  Future<void> _toggleBlockedApp(
    InstalledAppInfo app, {
    required bool blocked,
  }) async {
    if (_saving) return;

    final previous = _blockedPackages;
    final next = {..._blockedPackages};
    if (blocked) {
      next.add(app.packageName);
    } else {
      next.remove(app.packageName);
    }

    setState(() {
      _blockedPackages = next;
      _saving = true;
    });

    try {
      await _blockingService.syncBlockedPackages(next);
      if (!mounted) return;
      final t = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            blocked ? t.appBlocked(app.appName) : t.appUnblocked(app.appName),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _blockedPackages = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _openAccessibilitySettings() async {
    await _blockingService.openAccessibilitySettings();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _refreshPermissions();
  }

  Future<void> _openUsageAccessSettings() async {
    await _deviceStats.openUsageAccessSettings();
  }

  List<InstalledAppInfo> get _visibleApps {
    final normalizedQuery = _query.toLowerCase();
    final visible = _installedApps.where((app) {
      if (normalizedQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(normalizedQuery) ||
          app.packageName.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);

    visible.sort((left, right) {
      final leftBlocked = _blockedPackages.contains(left.packageName);
      final rightBlocked = _blockedPackages.contains(right.packageName);
      if (leftBlocked != rightBlocked) {
        return leftBlocked ? -1 : 1;
      }
      return left.appName.toLowerCase().compareTo(right.appName.toLowerCase());
    });

    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final palette = ChildPalette.of(context);

    if (!_blockingService.isSupported || !Platform.isAndroid) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: AppColors.textPrimaryLight,
          title: Text(t.appBlockingTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t.appBlockingUnsupported,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      );
    }

    final visibleApps = _visibleApps;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryLight,
        title: Text(
          t.appBlockingTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(showLoader: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              AppCard(
                color: palette.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Family security',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.appBlockingHeadline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.appBlockingDescription,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusBadge(
                          text: '${_blockedPackages.length} ${t.blocked}',
                          color: Colors.white,
                          background: Colors.white.withValues(alpha: 0.16),
                        ),
                        StatusBadge(
                          text: '${_installedApps.length} ${t.appLabel}',
                          color: Colors.white,
                          background: Colors.white.withValues(alpha: 0.16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PermissionCard(
                icon: Icons.accessibility_new_rounded,
                iconColor: (_accessibilityEnabled ?? false)
                    ? AppColors.success
                    : AppColors.warning,
                title: t.enableAccessibilityService,
                description: t.accessibilityServiceDescription,
                badge: (_accessibilityEnabled ?? false)
                    ? t.statusEnabled
                    : t.statusNeeded,
                badgeColor: (_accessibilityEnabled ?? false)
                    ? AppColors.success
                    : AppColors.warning,
                buttonLabel: t.openAccessibilitySettingsLabel,
                onPressed: _openAccessibilitySettings,
              ),
              const SizedBox(height: 12),
              _PermissionCard(
                icon: Icons.hourglass_top_rounded,
                iconColor: palette.primary,
                title: t.allowUsageAccess,
                description: t.usageAccessDescription,
                badge: t.optionalLabel,
                badgeColor: palette.primary,
                buttonLabel: t.openUsageAccess,
                onPressed: _openUsageAccessSettings,
              ),
              const SizedBox(height: 16),
              AppCard(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: t.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: InputBorder.none,
                    isDense: true,
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => _searchController.clear(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                AppCard(
                  color: AppColors.dangerSoft,
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (visibleApps.isEmpty)
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      _query.isEmpty ? t.noData : t.noAppsFound,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                ...visibleApps.map(
                  (app) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _InstalledAppTile(
                      app: app,
                      blocked: _blockedPackages.contains(app.packageName),
                      disabled: _saving,
                      onChanged: (value) => _toggleBlockedApp(
                        app,
                        blocked: value,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String badge;
  final Color badgeColor;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              StatusBadge(text: badge, color: badgeColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstalledAppTile extends StatelessWidget {
  const _InstalledAppTile({
    required this.app,
    required this.blocked,
    required this.disabled,
    required this.onChanged,
  });

  final InstalledAppInfo app;
  final bool blocked;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent =
        blocked ? AppColors.danger : ChildPalette.of(context).primary;

    return AppCard(
      child: Row(
        children: [
          AvatarCircle(
            initials:
                app.appName.isNotEmpty ? app.appName[0].toUpperCase() : 'A',
            color: accent,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: blocked,
            onChanged: disabled ? null : onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
