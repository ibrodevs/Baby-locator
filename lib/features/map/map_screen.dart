import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../activity/activity_screen.dart';
import '../chat/chat_screen.dart';
import '../parent/children_list_screen.dart';
import '../settings/settings_screen.dart';
import 'adaptive_map.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Timer? _poll;
  String? _err;
  int? _selectedIdx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      await _fetchAll();
      _startPolling();
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    try {
      final data = await ApiClient.instance.allChildrenLocations();
      if (!mounted) return;
      ref.read(allChildrenLocationsProvider.notifier).setFromApi(data);
      setState(() => _err = null);
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
    final t = S.of(context);
    final session = ref.watch(sessionProvider);
    final children = ref.watch(allChildrenLocationsProvider);
    final hasChildren = children.isNotEmpty;
    final selected = _selectedIdx != null && _selectedIdx! < children.length
        ? children[_selectedIdx!]
        : null;

    final mapChild = selected ?? (hasChildren ? children.first : null);

    return SafeArea(
      child: Column(
        children: [
          BrandHeader(
            leading: AvatarCircle(
              initials: (session.user?.displayName.isNotEmpty ?? false)
                  ? session.user!.displayName[0].toUpperCase()
                  : 'P',
              color: AppColors.primary,
              size: 36,
              image: session.user?.avatarUrl != null
                  ? NetworkImage(session.user!.avatarUrl!)
                  : null,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.people_alt_outlined,
                      color: AppColors.textPrimaryLight),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ChildrenListScreen()));
                    _fetchAll();
                  },
                ),
                GearButton(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Map
                Positioned.fill(
                  child: hasChildren && mapChild != null
                      ? AdaptiveMap(
                          latitude: mapChild.lat,
                          longitude: mapChild.lng,
                          children: children,
                          selectedIndex: _selectedIdx,
                          onChildTapped: (idx) {
                            setState(() => _selectedIdx = idx);
                          },
                        )
                      : _EmptyMapPlaceholder(
                          hasChildren: hasChildren,
                          error: _err,
                          onManage: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ChildrenListScreen()),
                            );
                            _fetchAll();
                          },
                        ),
                ),
                // Action buttons (LOUD / AROUND)
                if (hasChildren)
                  Positioned(
                    right: 16,
                    top: 20,
                    child: Column(
                      children: [
                        _MapActionButton(
                          icon: Icons.volume_up_rounded,
                          label: t.loud,
                          color: AppColors.primary,
                          onTap: () {
                            // TODO: implement loud signal
                          },
                        ),
                        const SizedBox(height: 12),
                        _MapActionButton(
                          icon: Icons.radar_rounded,
                          label: t.around,
                          color: AppColors.success,
                          onTap: () => setState(() => _selectedIdx = null),
                        ),
                      ],
                    ),
                  ),
                // Bottom child info card
                if (hasChildren)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: selected != null
                        ? _ChildInfoCard(
                            loc: selected,
                            onClose: () => setState(() => _selectedIdx = null),
                            onMessage: () => _openChat(context, selected),
                            onHistory: () => _openActivity(context, selected),
                          )
                        : _ChildCarousel(
                            children: children,
                            onSelect: (idx) =>
                                setState(() => _selectedIdx = idx),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, ChildLocation loc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialSelectedChildId: loc.childId),
      ),
    );
  }

  void _openActivity(BuildContext context, ChildLocation loc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityScreen(initialSelectedChildId: loc.childId),
      ),
    );
  }
}

class _EmptyMapPlaceholder extends StatelessWidget {
  const _EmptyMapPlaceholder({
    required this.hasChildren,
    this.error,
    required this.onManage,
  });
  final bool hasChildren;
  final String? error;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      color: AppColors.chipGrey,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_searching,
                size: 48, color: AppColors.textSecondaryLight),
            const SizedBox(height: 12),
            Text(
              hasChildren ? t.waitingForLocation : t.addChildToTrack,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondaryLight),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.danger)),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onManage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.people),
              label: Text(t.manageChildren),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCarousel extends StatelessWidget {
  const _ChildCarousel({required this.children, required this.onSelect});
  final List<ChildLocation> children;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white70, Colors.white],
          stops: [0.0, 0.3, 1.0],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        itemCount: children.length,
        itemBuilder: (_, i) {
          final c = children[i];
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AvatarCircle(
                        initials:
                            c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        size: 32,
                        color: AppColors.primary,
                        image: c.avatarUrl != null
                            ? NetworkImage(c.avatarUrl!)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        c.active ? Icons.check_circle : Icons.error,
                        size: 12,
                        color: c.active ? AppColors.success : AppColors.danger,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        c.active ? t.active : t.inactive,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              c.active ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.battery_full,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 2),
                      Text('${c.battery}%',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
  const _ChildInfoCard({
    required this.loc,
    this.onClose,
    this.onMessage,
    this.onHistory,
  });
  final ChildLocation loc;
  final VoidCallback? onClose;
  final VoidCallback? onMessage;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
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
          // Name + battery + close
          Row(
            children: [
              AvatarCircle(
                initials: loc.name.isNotEmpty ? loc.name[0].toUpperCase() : '?',
                size: 48,
                color: AppColors.primary,
                image:
                    loc.avatarUrl != null ? NetworkImage(loc.avatarUrl!) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
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
                    Icon(
                      _batteryIcon(loc.battery),
                      size: 14,
                      color: _batteryColor(loc.battery),
                    ),
                    const SizedBox(width: 4),
                    Text('${loc.battery}%',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Status row
          Row(
            children: [
              Icon(
                loc.active ? Icons.check_circle : Icons.error,
                size: 16,
                color: loc.active ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 6),
              Text(
                t.lastUpdated(_ago(context, loc.updatedAt)),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                loc.active ? t.statusActive : t.statusPaused,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: loc.active ? AppColors.success : AppColors.danger,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Current location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.currentLocation,
                      style: const TextStyle(
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
          const SizedBox(height: 16),
          // Action buttons: Message + History
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    t.messageChild(loc.name),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onHistory,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimaryLight,
                    side: const BorderSide(color: AppColors.dividerLight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    t.history,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
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

  static String _ago(BuildContext context, DateTime t) {
    final tr = S.of(context);
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return tr.justNow;
    if (d.inMinutes < 60) return tr.minutesAgo(d.inMinutes);
    return tr.hoursAgo(d.inHours);
  }
}
