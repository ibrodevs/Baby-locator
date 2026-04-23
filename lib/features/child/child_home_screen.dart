import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:record/record.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/services/app_blocking_service.dart';
import '../../core/services/device_stats_service.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../auth/onboarding_screen.dart';
import '../map/adaptive_map.dart';

class ChildHomeScreen extends ConsumerStatefulWidget {
  const ChildHomeScreen({super.key});
  @override
  ConsumerState<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends ConsumerState<ChildHomeScreen>
    with WidgetsBindingObserver {
  final _svc = LocationService();
  final _battery = Battery();
  final _deviceStats = const DeviceStatsService();
  final _appBlocking = AppBlockingService.instance;
  StreamSubscription<LocationFix>? _sub;
  StreamSubscription<BatteryState>? _batterySub;
  LocationPermissionStatus? _status;
  bool _starting = false;
  bool _syncingStats = false;
  String? _apiError;
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  bool? _usageAccessGranted;
  bool? _accessibilityBlockingEnabled;
  bool? _ignoringBatteryOptimizations;
  Timer? _statsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readBattery();
      _start();
      _prepareAroundPermission();
      _syncDeviceStats();
      _loadBlockedApps();
      _refreshAccessibilityStatus();
      _refreshBatteryOptimizationStatus();
      // Background service is now managed by app.dart (session lifecycle),
      // not by this screen — so we don't start/stop it here.
      _statsTimer = Timer.periodic(
        const Duration(minutes: 3),
        (_) => _syncDeviceStats(),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _readBattery();
      _syncDeviceStats();
      _loadBlockedApps();
      _refreshAccessibilityStatus();
      _refreshBatteryOptimizationStatus();
    }
  }

  Future<void> _refreshBatteryOptimizationStatus() async {
    if (!Platform.isAndroid) return;
    try {
      final ignored = await _deviceStats.isIgnoringBatteryOptimizations();
      if (!mounted) return;
      setState(() => _ignoringBatteryOptimizations = ignored);
    } catch (_) {}
  }

  Future<void> _refreshAccessibilityStatus() async {
    if (!Platform.isAndroid) return;
    try {
      final enabled = await _appBlocking.isAccessibilityServiceEnabled();
      if (!mounted) return;
      setState(() => _accessibilityBlockingEnabled = enabled);
    } catch (_) {}
  }

  Future<void> _openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _appBlocking.openAccessibilitySettings();
    } catch (_) {}
  }

  Future<void> _loadBlockedApps() async {
    try {
      final childId = ref.read(sessionProvider).user?.id;
      if (childId == null) return;

      final blocked = await ApiClient.instance.getBlockedApps(childId);
      final remotePackages = blocked
          .map((item) => (item as Map)['package_name'] as String? ?? '')
          .where((pkg) => pkg.isNotEmpty)
          .toSet();

      await _appBlocking.syncBlockedPackages(remotePackages);
    } catch (_) {}
  }

  Future<void> _readBattery() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
          _batteryState = state;
        });
      }
    } catch (_) {}
    _batterySub = _battery.onBatteryStateChanged.listen((state) async {
      try {
        final level = await _battery.batteryLevel;
        if (mounted) {
          setState(() {
            _batteryLevel = level;
            _batteryState = state;
          });
        }
        final currentLoc = ref.read(childLocationProvider);
        if (currentLoc != null) {
          final user = ref.read(sessionProvider).user;
          ref.read(childLocationProvider.notifier).setLocal(
                lat: currentLoc.lat,
                lng: currentLoc.lng,
                address: currentLoc.address,
                battery: level,
                charging: state == BatteryState.charging ||
                    state == BatteryState.full,
                active: currentLoc.active,
                name: currentLoc.name,
                childId: user?.id ?? currentLoc.childId,
                avatarUrl: user?.avatarUrl ?? currentLoc.avatarUrl,
              );
          await ApiClient.instance.shareLocation(
            lat: currentLoc.lat,
            lng: currentLoc.lng,
            address: currentLoc.address,
            battery: level,
            charging:
                state == BatteryState.charging || state == BatteryState.full,
            active: currentLoc.active,
          );
        }
        await _syncDeviceStats();
      } catch (_) {}
    });
  }

  Future<void> _start() async {
    if (_starting) return;
    _starting = true;
    final status = await _svc.ensurePermission(
      requireBackground: Platform.isAndroid,
    );
    if (!mounted) return;
    setState(() => _status = status);
    if (status != LocationPermissionStatus.granted) {
      _starting = false;
      return;
    }
    try {
      final first = await _svc.currentOnce();
      if (first != null && mounted) {
        _updateLocal(first);
        await _push(first);
      }
    } catch (_) {}
    _sub = _svc.watch().listen((fix) async {
      _updateLocal(fix);
      await _push(fix);
    });
    _starting = false;
  }

  Future<void> _prepareAroundPermission() async {
    final recorder = AudioRecorder();
    try {
      await recorder.hasPermission();
    } catch (_) {
      // Best-effort only. Around will fail later if the permission stays denied.
    } finally {
      await recorder.dispose();
    }
  }

  void _updateLocal(LocationFix fix) {
    final user = ref.read(sessionProvider).user;
    ref.read(childLocationProvider.notifier).setLocal(
          lat: fix.lat,
          lng: fix.lng,
          address: fix.address,
          battery: _batteryLevel,
          charging: _isCharging,
          active: true,
          name: user?.displayName ?? 'Me',
          childId: user?.id,
          avatarUrl: user?.avatarUrl,
        );
  }

  Future<void> _push(LocationFix fix) async {
    try {
      await ApiClient.instance.shareLocation(
        lat: fix.lat,
        lng: fix.lng,
        address: fix.address,
        battery: _batteryLevel,
        charging: _isCharging,
        active: true,
      );
      if (_apiError != null && mounted) setState(() => _apiError = null);
    } on SocketException {
      // No internet – ignore silently, will retry on next fix.
    } on http.ClientException {
      // Network error (wraps SocketException) – ignore silently.
    } catch (e) {
      if (mounted) setState(() => _apiError = e.toString());
    }
  }

  Future<void> _syncDeviceStats() async {
    if (_syncingStats) return;
    _syncingStats = true;
    try {
      final payload = await _deviceStats.readPayload(
        battery: _batteryLevel,
        charging: _batteryState == BatteryState.charging ||
            _batteryState == BatteryState.full,
      );
      if (mounted) {
        setState(() => _usageAccessGranted = payload.usageAccessGranted);
      }
      await ApiClient.instance.syncDeviceStats(payload.toJson());
      if (_apiError != null && mounted) setState(() => _apiError = null);
    } on SocketException {
      // No internet – ignore silently, will retry on next timer tick.
    } on http.ClientException {
      // Network error (wraps SocketException) – ignore silently.
    } catch (e) {
      if (mounted) setState(() => _apiError = e.toString());
    } finally {
      _syncingStats = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _batterySub?.cancel();
    _statsTimer?.cancel();
    // DO NOT stop the background service here — it must keep running
    // even when this screen is disposed or the app goes to background.
    _svc.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final loc = ref.watch(childLocationProvider);
    final user = ref.watch(sessionProvider).user;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  AvatarCircle(
                    initials: (user?.displayName.isNotEmpty ?? false)
                        ? user!.displayName[0].toUpperCase()
                        : 'C',
                    color: AppColors.primary,
                    size: 40,
                    image: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            t.helloUser(user?.displayName ??
                                user?.username ??
                                t.friendLabel),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight)),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(t.kidMode,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600)),
                            Icon(
                              _batteryIcon(_batteryLevel),
                              size: 14,
                              color: _batteryColor(_batteryLevel),
                            ),
                            Text('$_batteryLevel%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _batteryColor(_batteryLevel),
                                )),
                            _ChargingBadge(isCharging: _isCharging),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.textPrimaryLight),
                    onPressed: () async {
                      final navigator =
                          Navigator.of(context, rootNavigator: true);
                      await ref.read(sessionProvider.notifier).logout();
                      unawaited(navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const OnboardingScreen()),
                        (route) => false,
                      ));
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  if (_status != null &&
                      _status != LocationPermissionStatus.granted)
                    _PermissionBanner(
                      status: _status!,
                      onRetry: _start,
                      onOpenSettings: () async => Geolocator.openAppSettings(),
                      onOpenLocation: () async =>
                          Geolocator.openLocationSettings(),
                    ),
                  if (Platform.isAndroid &&
                      _ignoringBatteryOptimizations == false)
                    _BatteryOptimizationBanner(
                      onOpenSettings: () async {
                        await _deviceStats.openBatteryOptimizationSettings();
                        if (!mounted) return;
                        await Future<void>.delayed(const Duration(seconds: 1));
                        await _refreshBatteryOptimizationStatus();
                      },
                    ),
                  if (_apiError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        t.syncError(_apiError!),
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 12),
                      ),
                    ),
                  if (_usageAccessGranted == false &&
                      _deviceStats.supportsUsageAccess)
                    _UsageAccessBanner(
                      onOpenSettings: () async {
                        await _deviceStats.openUsageAccessSettings();
                        if (!mounted) return;
                        await Future<void>.delayed(const Duration(seconds: 1));
                        await _syncDeviceStats();
                      },
                    ),
                  if (_usageAccessGranted == false &&
                      !_deviceStats.supportsUsageAccess)
                    const _UsageAccessUnsupportedBanner(),
                  if (Platform.isAndroid &&
                      _accessibilityBlockingEnabled == false)
                    _AccessibilityBlockingBanner(
                      onEnable: () async {
                        await _openAccessibilitySettings();
                        if (!mounted) return;
                        await Future<void>.delayed(const Duration(seconds: 1));
                        await _refreshAccessibilityStatus();
                      },
                    ),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18)),
                          child: SizedBox(
                            height: 220,
                            child: AdaptiveMap(
                              latitude: loc?.lat ?? 0,
                              longitude: loc?.lng ?? 0,
                              children: loc != null ? [loc] : [],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.myLocation,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimaryLight)),
                              const SizedBox(height: 6),
                              Text(loc?.address ?? t.waitingForGps,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondaryLight)),
                              const SizedBox(height: 8),
                              _ChargingBadge(isCharging: _isCharging),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 16, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc != null
                                        ? t.sharedWithParent(
                                            _ago(loc.updatedAt))
                                        : t.notSharedYet,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _BigActionTile(
                          icon: Icons.notifications_active,
                          label: t.imSafe,
                          color: AppColors.success,
                          onTap: () async {
                            // Send "I'm safe" message to parent
                            final user = ref.read(sessionProvider).user;
                            if (user != null) {
                              try {
                                await ApiClient.instance.sendMessage(
                                  user.id,
                                  '${t.imSafe}! \u2705',
                                );
                              } catch (_) {}
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(S.of(context).sentImSafe)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigActionTile(
                          icon: Icons.emergency,
                          label: t.sos,
                          color: AppColors.danger,
                          onTap: () async {
                            final localizations = S.of(context);
                            final user = ref.read(sessionProvider).user;
                            if (user != null) {
                              final loc = ref.read(childLocationProvider);
                              // Send SOS alert via dedicated endpoint
                              try {
                                await ApiClient.instance.sendSos(
                                  lat: loc?.lat,
                                  lng: loc?.lng,
                                  address: loc?.address,
                                );
                              } catch (_) {}
                              // Also send chat message
                              final locationText = loc != null
                                  ? localizations.sosLocation(loc.address)
                                  : '';
                              try {
                                await ApiClient.instance.sendMessage(
                                  user.id,
                                  '${localizations.sosMessage}$locationText',
                                );
                              } catch (_) {}
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).sosSent),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _batteryIcon(int level) {
    if (level > 80) return Icons.battery_full;
    if (level > 50) return Icons.battery_5_bar;
    if (level > 20) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }

  Color _batteryColor(int level) {
    if (level > 50) return AppColors.success;
    if (level > 20) return AppColors.warning;
    return AppColors.danger;
  }

  bool get _isCharging =>
      _batteryState == BatteryState.charging ||
      _batteryState == BatteryState.full;

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return S.of(context).justNow;
    if (d.inMinutes < 60) return S.of(context).minutesAgo(d.inMinutes);
    return S.of(context).hoursAgo(d.inHours);
  }
}

class _ChargingBadge extends StatelessWidget {
  const _ChargingBadge({required this.isCharging});

  final bool isCharging;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final color = isCharging ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCharging ? Icons.bolt_rounded : Icons.power_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isCharging ? t.chargingShort : t.notChargingShort,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageAccessBanner extends StatelessWidget {
  const _UsageAccessBanner({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.allowUsageAccess,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.usageAccessDescription,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpenSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                t.openUsageAccess,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageAccessUnsupportedBanner extends StatelessWidget {
  const _UsageAccessUnsupportedBanner();

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.iphoneLimitation,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.iphoneUsageDescription,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessibilityBlockingBanner extends StatelessWidget {
  const _AccessibilityBlockingBanner({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.enableAccessibilityService,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.accessibilityServiceDescription,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEnable,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                t.openAppSettings,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigActionTile extends StatelessWidget {
  const _BigActionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.status,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onOpenLocation,
  });
  final LocationPermissionStatus status;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLocation;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    late final String title;
    late final String body;
    late final String button;
    late final VoidCallback action;
    switch (status) {
      case LocationPermissionStatus.serviceOff:
        title = t.turnOnLocation;
        body = t.locationIsOff;
        button = t.openLocationSettings;
        action = onOpenLocation;
        break;
      case LocationPermissionStatus.deniedForever:
        title = t.locationBlocked;
        body = t.enableLocationAccess;
        button = t.openAppSettings;
        action = onOpenSettings;
        break;
      case LocationPermissionStatus.denied:
        title = t.allowLocationToShare;
        body = t.grantLocationPermission;
        button = t.allowLocation;
        action = onRetry;
        break;
      case LocationPermissionStatus.backgroundDenied:
        title = t.allowLocationAllTheTime;
        body = t.allowLocationAllTheTimeDescription;
        button = t.openAppSettings;
        action = onOpenSettings;
        break;
      case LocationPermissionStatus.granted:
        return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_off, color: AppColors.danger, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            )
          ]),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimaryLight)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(button,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryOptimizationBanner extends StatelessWidget {
  const _BatteryOptimizationBanner({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.battery_alert_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.disableBatteryOptimization,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.batteryOptimizationDescription,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpenSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                t.allowUnrestricted,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
