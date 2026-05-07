import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/providers/zone_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../l10n/app_localizations.dart';
import '../activity/zone_edit_screen.dart';
import 'adaptive_map.dart';
import 'map_models.dart';

/// "Places on the map" — shows children + safe zones together so the parent
/// can see and manage zones in one place.
class MapPlacesScreen extends ConsumerStatefulWidget {
  const MapPlacesScreen({super.key});

  @override
  ConsumerState<MapPlacesScreen> createState() => _MapPlacesScreenState();
}

class _MapPlacesScreenState extends ConsumerState<MapPlacesScreen> {
  int? _focusedZoneId;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final children = ref.watch(allChildrenLocationsProvider);
    final zonesAsync = ref.watch(safeZonesProvider);
    final zones = zonesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <SafeZone>[],
    );

    final mapCenter = _resolveMapCenter(zones, children);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: t.placesOnMap,
              subtitle: t.placesAndChildren,
              onClose: () => Navigator.of(context).maybePop(),
              onAdd: _openCreateZone,
              onRefresh: () => ref.read(safeZonesProvider.notifier).load(),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AdaptiveMap(
                      latitude: mapCenter.latitude,
                      longitude: mapCenter.longitude,
                      children: children,
                      circles: _buildCircles(zones),
                      followTarget: false,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 12,
                    child: _SummaryBar(
                      total: zones.length,
                      activeNow: zones.where((z) => z.isActiveToday).length,
                    ),
                  ),
                ],
              ),
            ),
            _ZonesPanel(
              zonesAsync: zonesAsync,
              focusedZoneId: _focusedZoneId,
              onTapZone: _focusZone,
              onToggleZone: _toggleZone,
              onEditZone: _openEditZone,
              onDeleteZone: _confirmDeleteZone,
              onAddZone: _openCreateZone,
              onRetry: () => ref.read(safeZonesProvider.notifier).load(),
            ),
          ],
        ),
      ),
    );
  }

  MapLatLng _resolveMapCenter(
    List<SafeZone> zones,
    List<ChildLocation> children,
  ) {
    if (_focusedZoneId != null) {
      final z = zones.firstWhere(
        (zone) => zone.id == _focusedZoneId,
        orElse: () => zones.isNotEmpty
            ? zones.first
            : SafeZone(
                id: -1,
                name: '',
                lat: 0,
                lng: 0,
                radius: 0,
                active: false,
                scheduleType: SafeZone.scheduleAlways,
                activeDays: const [],
              ),
      );
      if (z.id != -1) return MapLatLng(z.lat, z.lng);
    }
    if (zones.isNotEmpty) {
      double sumLat = 0;
      double sumLng = 0;
      for (final z in zones) {
        sumLat += z.lat;
        sumLng += z.lng;
      }
      return MapLatLng(sumLat / zones.length, sumLng / zones.length);
    }
    if (children.isNotEmpty) {
      return MapLatLng(children.first.lat, children.first.lng);
    }
    return const MapLatLng(55.7558, 37.6173);
  }

  List<MapCircle> _buildCircles(List<SafeZone> zones) {
    return [
      for (final z in zones)
        MapCircle(
          id: 'zone_${z.id}',
          center: MapLatLng(z.lat, z.lng),
          radiusMeters: z.radius,
          strokeColor: _zoneStrokeColor(z, focused: z.id == _focusedZoneId),
          fillColor: _zoneFillColor(z, focused: z.id == _focusedZoneId),
          strokeWidth: z.id == _focusedZoneId ? 3 : 2,
        ),
    ];
  }

  Color _zoneStrokeColor(SafeZone z, {required bool focused}) {
    if (!z.active) return AppColors.textMuted;
    if (!z.isActiveToday) return AppColors.warning;
    return focused ? AppColors.primaryDark : AppColors.primary;
  }

  Color _zoneFillColor(SafeZone z, {required bool focused}) {
    if (!z.active) {
      return AppColors.textMuted.withValues(alpha: 0.10);
    }
    if (!z.isActiveToday) {
      return AppColors.warning.withValues(alpha: 0.16);
    }
    return AppColors.primary.withValues(alpha: focused ? 0.26 : 0.18);
  }

  void _focusZone(SafeZone zone) {
    setState(() {
      _focusedZoneId = _focusedZoneId == zone.id ? null : zone.id;
    });
  }

  Future<void> _toggleZone(SafeZone zone, bool value) async {
    try {
      await ref
          .read(safeZonesProvider.notifier)
          .updateZone(zone.id, active: value);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> _openCreateZone() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ZoneEditScreen()),
    );
  }

  Future<void> _openEditZone(SafeZone zone) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ZoneEditScreen(zone: zone)),
    );
  }

  Future<void> _confirmDeleteZone(SafeZone zone) async {
    final t = S.of(context);
    final confirm = await showAppConfirmDialog(
      context: context,
      title: t.deleteZoneTitle,
      message: '${t.zone(zone.name)} ${t.deleteZoneMessage}',
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      type: AppFeedbackType.error,
    );
    if (confirm != true) return;
    try {
      await ref.read(safeZonesProvider.notifier).deleteZone(zone.id);
      if (!mounted) return;
      showAppSnackBar(
        context,
        t.placeDeleted,
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onClose,
    required this.onAdd,
    required this.onRefresh,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_rounded,
                color: AppColors.primary, size: 30),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.total, required this.activeNow});

  final int total;
  final int activeNow;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0
                      ? t.noSafeZonesYet
                      : t.placesCount(total),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (total > 0)
                  Text(
                    t.activeTodayCount(activeNow),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonesPanel extends StatelessWidget {
  const _ZonesPanel({
    required this.zonesAsync,
    required this.focusedZoneId,
    required this.onTapZone,
    required this.onToggleZone,
    required this.onEditZone,
    required this.onDeleteZone,
    required this.onAddZone,
    required this.onRetry,
  });

  final AsyncValue<List<SafeZone>> zonesAsync;
  final int? focusedZoneId;
  final ValueChanged<SafeZone> onTapZone;
  final void Function(SafeZone zone, bool value) onToggleZone;
  final ValueChanged<SafeZone> onEditZone;
  final ValueChanged<SafeZone> onDeleteZone;
  final VoidCallback onAddZone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.safeZones,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddZone,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    t.addNew,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Flexible(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final t = S.of(context);
    return zonesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.danger, size: 28),
            const SizedBox(height: 6),
            Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(t.retry),
            ),
          ],
        ),
      ),
      data: (zones) {
        if (zones.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 36, color: AppColors.textMuted),
                const SizedBox(height: 8),
                Text(
                  t.noSafeZonesYet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.createPlaceHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: onAddZone,
                  icon: const Icon(Icons.add),
                  label: Text(t.createSafeZone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          itemCount: zones.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final zone = zones[i];
            return _ZoneTile(
              zone: zone,
              focused: zone.id == focusedZoneId,
              onTap: () => onTapZone(zone),
              onToggle: (v) => onToggleZone(zone, v),
              onEdit: () => onEditZone(zone),
              onDelete: () => onDeleteZone(zone),
            );
          },
        );
      },
    );
  }
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({
    required this.zone,
    required this.focused,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final SafeZone zone;
  final bool focused;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final accent = !zone.active
        ? AppColors.textMuted
        : zone.isActiveToday
            ? AppColors.primary
            : AppColors.warning;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: focused ? AppColors.primarySoft : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focused ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.location_on_rounded, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name.isEmpty ? t.untitledPlace : zone.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _summary(context, zone),
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
            Switch(
              value: zone.active,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.success,
              onChanged: onToggle,
            ),
            PopupMenuButton<_ZoneAction>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppColors.textSecondaryLight),
              onSelected: (action) {
                switch (action) {
                  case _ZoneAction.edit:
                    onEdit();
                    break;
                  case _ZoneAction.delete:
                    onDelete();
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _ZoneAction.edit,
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 10),
                      Text(t.editLabel),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _ZoneAction.delete,
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.danger),
                      const SizedBox(width: 10),
                      Text(
                        t.delete,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _summary(BuildContext context, SafeZone zone) {
    final t = S.of(context);
    final radius = zone.radius >= 1000
        ? '${(zone.radius / 1000).toStringAsFixed(1)} км'
        : '${zone.radius.toStringAsFixed(0)} м';
    final schedule = !zone.active
        ? t.disabledSchedule
        : zone.isAlwaysActive
            ? t.always
            : zone.activeDays.isEmpty
                ? t.noDaysSelected
                : zone.activeDays
                    .map((d) => _weekdayLabel(t, d))
                    .join(', ');
    return t.radiusSummary(radius, schedule);
  }

  String _weekdayLabel(S t, int day) => switch (day) {
        1 => t.mon,
        2 => t.tue,
        3 => t.wed,
        4 => t.thu,
        5 => t.fri,
        6 => t.sat,
        7 => t.sun,
        _ => day.toString(),
      };
}

enum _ZoneAction { edit, delete }
