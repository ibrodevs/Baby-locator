import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../map/adaptive_map.dart';

class ChildHomeScreen extends ConsumerStatefulWidget {
  const ChildHomeScreen({super.key});
  @override
  ConsumerState<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends ConsumerState<ChildHomeScreen> {
  final _svc = LocationService();
  StreamSubscription<LocationFix>? _sub;
  LocationPermissionStatus? _status;
  bool _starting = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (_starting) return;
    _starting = true;
    final status = await _svc.ensurePermission();
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

  void _updateLocal(LocationFix fix) {
    ref.read(childLocationProvider.notifier).setLocal(
          lat: fix.lat,
          lng: fix.lng,
          address: fix.address,
          active: true,
          name: ref.read(sessionProvider).user?.displayName ?? 'Me',
        );
  }

  Future<void> _push(LocationFix fix) async {
    try {
      await ApiClient.instance.shareLocation(
        lat: fix.lat,
        lng: fix.lng,
        address: fix.address,
      );
      if (_apiError != null && mounted) setState(() => _apiError = null);
    } catch (e) {
      if (mounted) setState(() => _apiError = e.toString());
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _svc.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${user?.displayName ?? user?.username ?? 'friend'}!',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight)),
                        const Text('Kid mode',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.textPrimaryLight),
                    onPressed: () =>
                        ref.read(sessionProvider.notifier).logout(),
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
                      onOpenSettings: () async =>
                          Geolocator.openAppSettings(),
                      onOpenLocation: () async =>
                          Geolocator.openLocationSettings(),
                    ),
                  if (_apiError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Sync error: $_apiError',
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 12),
                      ),
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
                              label: 'You',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('My Location',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color:
                                          AppColors.textPrimaryLight)),
                              const SizedBox(height: 6),
                              Text(loc?.address ?? 'Waiting for GPS…',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          AppColors.textSecondaryLight)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 16,
                                      color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc != null
                                        ? 'Shared with parent · ${_ago(loc.updatedAt)}'
                                        : 'Not shared yet',
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
                          label: "I'm Safe",
                          color: AppColors.success,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Sent "I\'m safe" to your parent')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigActionTile(
                          icon: Icons.emergency,
                          label: 'SOS',
                          color: AppColors.danger,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'SOS sent — parent will be notified'),
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

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
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
    late final String title;
    late final String body;
    late final String button;
    late final VoidCallback action;
    switch (status) {
      case LocationPermissionStatus.serviceOff:
        title = 'Turn on Location Services';
        body = 'Location is off. Enable it to share with parent.';
        button = 'Open Location Settings';
        action = onOpenLocation;
        break;
      case LocationPermissionStatus.deniedForever:
        title = 'Location permission blocked';
        body = 'Enable location access in system settings.';
        button = 'Open App Settings';
        action = onOpenSettings;
        break;
      case LocationPermissionStatus.denied:
        title = 'Allow location to share';
        body = 'Grant permission so your parent can see where you are.';
        button = 'Allow Location';
        action = onRetry;
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
            const Icon(Icons.location_off,
                color: AppColors.danger, size: 20),
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
