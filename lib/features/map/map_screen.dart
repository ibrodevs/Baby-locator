import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../parent/children_list_screen.dart';
import 'adaptive_map.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Timer? _poll;
  String _childName = 'Child';
  String? _err;
  List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      final list = (await ApiClient.instance.listChildren())
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() => _children = list);
      if (list.isNotEmpty && ref.read(selectedChildIdProvider) == null) {
        ref.read(selectedChildIdProvider.notifier).state =
            list.first['id'] as int;
      }
      _startPolling();
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  Future<void> _fetch() async {
    final id = ref.read(selectedChildIdProvider);
    if (id == null) return;
    final child = _children.firstWhere(
      (c) => c['id'] == id,
      orElse: () => {'display_name': 'Child', 'username': 'child'},
    );
    final name = ((child['display_name'] as String?)?.isNotEmpty ?? false)
        ? child['display_name'] as String
        : child['username'] as String;
    _childName = name;
    try {
      final loc = await ApiClient.instance.childLatest(id);
      if (!mounted) return;
      if (loc != null) {
        ref.read(childLocationProvider.notifier).setFromApi(loc, name: name);
        setState(() => _err = null);
      } else {
        setState(() => _err = 'Child has not shared location yet');
      }
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedChildIdProvider, (_, __) => _fetch());
    final loc = ref.watch(childLocationProvider);
    final hasData = loc != null;
    return SafeArea(
      child: Column(
        children: [
          BrandHeader(
            leading: const AvatarCircle(
                initials: 'P', color: AppColors.primary, size: 36),
            trailing: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.people_alt_outlined,
                      color: AppColors.textPrimaryLight),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ChildrenListScreen()));
                    _init();
                  },
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasData
                      ? AdaptiveMap(
                          latitude: loc.lat,
                          longitude: loc.lng,
                          label: loc.name.isNotEmpty ? loc.name[0] : '?',
                        )
                      : Container(
                          color: AppColors.chipGrey,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_searching,
                                    size: 48,
                                    color: AppColors.textSecondaryLight),
                                const SizedBox(height: 12),
                                Text(
                                  _children.isEmpty
                                      ? 'Add a child to start tracking'
                                      : 'Waiting for child to share location…',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color:
                                          AppColors.textSecondaryLight),
                                ),
                                if (_err != null) ...[
                                  const SizedBox(height: 8),
                                  Text(_err!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.danger)),
                                ],
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ChildrenListScreen()),
                                    );
                                    _init();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.people),
                                  label: const Text('Manage children'),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                if (hasData)
                  Positioned(
                    right: 16,
                    top: 20,
                    child: Column(
                      children: [
                        _MapActionButton(
                          icon: Icons.refresh,
                          label: 'SYNC',
                          color: AppColors.primary,
                          onTap: _fetch,
                        ),
                        const SizedBox(height: 12),
                        _MapActionButton(
                          icon: Icons.track_changes_rounded,
                          label: 'AROUND',
                          color: AppColors.success,
                          onTap: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text('Scanning nearby'))),
                        ),
                      ],
                    ),
                  ),
                if (hasData)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _ChildInfoCard(loc: loc, name: _childName),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black38,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildInfoCard extends StatelessWidget {
  const _ChildInfoCard({required this.loc, required this.name});
  final ChildLocation loc;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.chipGrey,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.battery_full,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text('${loc.battery}%',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                loc.active ? Icons.check_circle : Icons.error,
                size: 16,
                color: loc.active ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 6),
              Text(
                'Last updated: ${_ago(loc.updatedAt)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                loc.active ? 'ACTIVE' : 'PAUSED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: loc.active ? AppColors.success : AppColors.danger,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT LOCATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.address.isEmpty
                          ? '${loc.lat.toStringAsFixed(5)}, ${loc.lng.toStringAsFixed(5)}'
                          : loc.address,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
  }
}
