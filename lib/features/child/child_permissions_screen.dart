import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:record/record.dart';

import '../../core/services/app_blocking_service.dart';
import '../../core/services/device_stats_service.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/child_theme.dart';

class ChildPermissionsScreen extends StatefulWidget {
  const ChildPermissionsScreen({super.key});

  @override
  State<ChildPermissionsScreen> createState() => _ChildPermissionsScreenState();
}

class _ChildPermissionsScreenState extends State<ChildPermissionsScreen>
    with WidgetsBindingObserver {
  final DeviceStatsService _deviceStats = const DeviceStatsService();
  final AppBlockingService _appBlocking = AppBlockingService.instance;
  final LocationService _locationService = LocationService();

  bool _loading = true;
  String? _error;

  bool _locationServiceEnabled = false;
  LocationPermission _locationPermission = LocationPermission.denied;
  bool _backgroundLocationGranted = false;
  bool _microphoneGranted = false;
  AuthorizationStatus _notificationStatus = AuthorizationStatus.notDetermined;
  bool _usageAccessGranted = false;
  bool _accessibilityEnabled = false;
  bool _batteryOptimizationDisabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStatuses());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStatuses(showLoader: false);
    }
  }

  Future<void> _loadStatuses({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final locationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      final locationPermission = await Geolocator.checkPermission();

      final recorder = AudioRecorder();
      bool microphoneGranted = false;
      try {
        microphoneGranted = await recorder.hasPermission();
      } finally {
        await recorder.dispose();
      }

      final notificationSettings =
          await FirebaseMessaging.instance.getNotificationSettings();

      bool usageAccessGranted = false;
      bool accessibilityEnabled = false;
      bool batteryOptimizationDisabled = true;
      bool backgroundLocationGranted = false;

      if (!kIsWeb && Platform.isAndroid) {
        try {
          final payload = await _deviceStats.readPayload(
            battery: 0,
            charging: false,
            days: 1,
          );
          usageAccessGranted = payload.usageAccessGranted;
        } catch (_) {}

        try {
          accessibilityEnabled =
              await _appBlocking.isAccessibilityServiceEnabled();
        } catch (_) {}

        try {
          batteryOptimizationDisabled =
              await _deviceStats.isIgnoringBatteryOptimizations();
        } catch (_) {}

        try {
          backgroundLocationGranted =
              (await ph.Permission.locationAlways.status).isGranted;
        } catch (_) {}
      } else if (!kIsWeb && Platform.isIOS) {
        backgroundLocationGranted =
            locationPermission == LocationPermission.always;
      } else {
        backgroundLocationGranted = true;
      }

      if (!mounted) return;
      setState(() {
        _locationServiceEnabled = locationServiceEnabled;
        _locationPermission = locationPermission;
        _backgroundLocationGranted = backgroundLocationGranted;
        _microphoneGranted = microphoneGranted;
        _notificationStatus = notificationSettings.authorizationStatus;
        _usageAccessGranted = usageAccessGranted;
        _accessibilityEnabled = accessibilityEnabled;
        _batteryOptimizationDisabled = batteryOptimizationDisabled;
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

  bool get _locationGranted =>
      _locationPermission == LocationPermission.always ||
      _locationPermission == LocationPermission.whileInUse;

  bool get _notificationGranted =>
      _notificationStatus == AuthorizationStatus.authorized ||
      _notificationStatus == AuthorizationStatus.provisional;

  Future<void> _requestLocationPermission() async {
    try {
      await Geolocator.requestPermission();
      await _loadStatuses(showLoader: false);
    } catch (_) {}
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      final status = await ph.Permission.microphone.status;
      if (status.isPermanentlyDenied) {
        await ph.openAppSettings();
      } else {
        final result = await ph.Permission.microphone.request();
        if (result.isPermanentlyDenied) {
          await ph.openAppSettings();
        }
      }
    } catch (_) {}
    await _loadStatuses(showLoader: false);
  }

  Future<void> _requestBackgroundLocation() async {
    try {
      final granted = await _locationService.requestBackgroundPermission();
      if (!granted && mounted) {
        // On Android 11+ the system only opens Settings for "Allow all the
        // time" — open the app page as a fallback so the user can toggle it.
        await ph.openAppSettings();
      }
    } catch (_) {}
    await _loadStatuses(showLoader: false);
  }

  Future<void> _openLocationSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await _loadStatuses(showLoader: false);
    } catch (_) {}
  }

  Future<void> _openUsageAccessSettings() async {
    try {
      await _deviceStats.openUsageAccessSettings();
    } catch (_) {}
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await _appBlocking.openAccessibilitySettings();
    } catch (_) {}
  }

  Future<void> _openBatteryOptimizationSettings() async {
    try {
      // First try the direct system prompt — it actually removes the
      // optimization in one tap when the user accepts.
      final shown = await _deviceStats.requestIgnoreBatteryOptimizations();
      if (!shown) {
        await _deviceStats.openBatteryOptimizationSettings();
      }
    } catch (_) {
      try {
        await _deviceStats.openBatteryOptimizationSettings();
      } catch (_) {}
    }
    await _loadStatuses(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final palette = ChildPalette.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryLight,
        title: const Text(
          'Разрешения',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => _loadStatuses(showLoader: false),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadStatuses(showLoader: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _IntroCard(
                palette: palette,
                loading: _loading,
                grantedCount: [
                  _locationGranted,
                  _backgroundLocationGranted,
                  _microphoneGranted,
                  _notificationGranted,
                  _usageAccessGranted,
                  _accessibilityEnabled,
                  _batteryOptimizationDisabled,
                ].where((it) => it).length,
                totalCount: 7,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _StatusMessage(message: _error!),
              ],
              const SizedBox(height: 16),
              _PermissionTile(
                palette: palette,
                icon: Icons.location_on_outlined,
                title: 'Геолокация',
                description: _locationServiceEnabled
                    ? (_locationGranted
                        ? 'Доступ к геолокации выдан.'
                        : 'Разрешение на геолокацию пока не выдано.')
                    : 'Служба геолокации на устройстве сейчас выключена.',
                granted: _locationGranted && _locationServiceEnabled,
                actionLabel: _locationGranted ? t.openAppSettings : 'Выдать доступ',
                onPressed: _locationGranted
                    ? _openLocationSettings
                    : _requestLocationPermission,
              ),
              const SizedBox(height: 12),
              _PermissionTile(
                palette: palette,
                icon: Icons.my_location_rounded,
                title: 'Геолокация в фоне',
                description: _backgroundLocationGranted
                    ? 'Разрешено «Всегда» — местоположение отправляется даже при выключенном экране.'
                    : _locationGranted
                        ? 'Без «Разрешить всегда» Android перестаёт присылать координаты, когда экран гаснет или приложение свёрнуто. Это главная причина, почему отслеживание «перестаёт работать».'
                        : 'Сначала выдайте обычное разрешение на геолокацию, затем включите «Разрешить всегда».',
                granted: _backgroundLocationGranted,
                actionLabel: _backgroundLocationGranted
                    ? t.openAppSettings
                    : 'Разрешить всегда',
                onPressed: _backgroundLocationGranted
                    ? _openLocationSettings
                    : _requestBackgroundLocation,
              ),
              const SizedBox(height: 12),
              _PermissionTile(
                palette: palette,
                icon: Icons.mic_none_rounded,
                title: 'Микрофон',
                description: _microphoneGranted
                    ? 'Разрешение на микрофон уже выдано.'
                    : 'Без этого разрешения функция «Вокруг» не сможет слышать звук рядом с ребёнком.',
                granted: _microphoneGranted,
                actionLabel: _microphoneGranted ? t.openAppSettings : 'Разрешить микрофон',
                onPressed: _microphoneGranted
                    ? _openLocationSettings
                    : _requestMicrophonePermission,
              ),
              const SizedBox(height: 12),
              _PermissionTile(
                palette: palette,
                icon: Icons.notifications_none_rounded,
                title: t.notifications,
                description: _notificationGranted
                    ? 'Уведомления разрешены.'
                    : 'Разрешите уведомления, чтобы не пропускать команды и важные события.',
                granted: _notificationGranted,
                actionLabel:
                    _notificationGranted ? t.openAppSettings : 'Разрешить уведомления',
                onPressed: _notificationGranted
                    ? _openLocationSettings
                    : _requestNotificationPermission,
              ),
              if (!kIsWeb && Platform.isAndroid) ...[
                const SizedBox(height: 12),
                _PermissionTile(
                  palette: palette,
                  icon: Icons.hourglass_top_rounded,
                  title: t.allowUsageAccess,
                  description: _usageAccessGranted
                      ? 'Доступ к статистике приложений уже выдан.'
                      : t.grantUsageAccessHint,
                  granted: _usageAccessGranted,
                  actionLabel: t.openUsageAccess,
                  onPressed: _openUsageAccessSettings,
                ),
                const SizedBox(height: 12),
                _PermissionTile(
                  palette: palette,
                  icon: Icons.accessibility_new_rounded,
                  title: t.enableAccessibilityService,
                  description: t.accessibilityServiceDescription,
                  granted: _accessibilityEnabled,
                  actionLabel: t.openAccessibilitySettingsLabel,
                  onPressed: _openAccessibilitySettings,
                ),
                const SizedBox(height: 12),
                _PermissionTile(
                  palette: palette,
                  icon: Icons.battery_charging_full_rounded,
                  title: t.disableBatteryOptimization,
                  description: t.batteryOptimizationDescription,
                  granted: _batteryOptimizationDisabled,
                  actionLabel: 'Открыть настройки',
                  onPressed: _openBatteryOptimizationSettings,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.palette,
    required this.loading,
    required this.grantedCount,
    required this.totalCount,
  });

  final ChildPalette palette;
  final bool loading;
  final int grantedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: palette.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Статус разрешений',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            loading
                ? 'Проверяем, какие доступы уже включены...'
                : 'Выдано разрешений: $grantedCount из $totalCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.actionLabel,
    required this.onPressed,
  });

  final ChildPalette palette;
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: granted
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: granted ? AppColors.success : AppColors.warning,
                ),
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
              _Badge(granted: granted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: granted
                    ? palette.primarySoft
                    : palette.primary,
                foregroundColor: granted ? palette.primary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: granted
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        granted ? 'Выдано' : 'Не выдано',
        style: TextStyle(
          color: granted ? AppColors.success : AppColors.warning,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
