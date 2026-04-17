import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/providers/zone_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../map/adaptive_map.dart';
import '../settings/settings_screen.dart';
import 'zone_edit_screen.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key, this.initialSelectedChildId});

  final int? initialSelectedChildId;

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  static const int _activityPreviewLimit = 5;

  List<Map<String, dynamic>> _children = [];
  int? _selectedChildId;
  List<_ActivityEvent> _events = [];
  bool _showAllEvents = false;
  int _safetyScore = 0;
  int _inZonePct = 0;
  int _totalUpdates = 0;
  int _inZoneUpdates = 0;
  String? _currentZoneName;
  bool _loading = true;

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
      if (list.isNotEmpty) {
        final selectedChildId = _resolveInitialChildId(list);
        ref.read(selectedChildIdProvider.notifier).state = selectedChildId;
        _selectedChildId = selectedChildId;
        await _loadData();
      } else {
        ref.read(selectedChildIdProvider.notifier).state = null;
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _resolveInitialChildId(List<Map<String, dynamic>> list) {
    final providerChildId = ref.read(selectedChildIdProvider);
    final preferredIds = [
      widget.initialSelectedChildId,
      providerChildId,
    ].whereType<int>();
    for (final id in preferredIds) {
      if (list.any((child) => child['id'] == id)) {
        return id;
      }
    }
    return list.first['id'] as int;
  }

  Future<void> _setSelectedChild(
    int id, {
    bool syncProvider = true,
  }) async {
    if (_selectedChildId == id) return;
    if (syncProvider) {
      ref.read(selectedChildIdProvider.notifier).state = id;
    }
    setState(() {
      _selectedChildId = id;
      _events = [];
      _showAllEvents = false;
      _safetyScore = 0;
      _inZonePct = 0;
      _totalUpdates = 0;
      _inZoneUpdates = 0;
      _currentZoneName = null;
      _loading = true;
    });
    await _loadData();
  }

  Future<void> _loadData() async {
    if (_selectedChildId == null) return;
    setState(() => _loading = true);
    try {
      // Load activity events and safety score in parallel
      final results = await Future.wait([
        ApiClient.instance.childActivity(_selectedChildId!),
        ApiClient.instance.childSafetyScore(_selectedChildId!),
      ]);
      if (!mounted) return;

      final activityData =
          (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
      final scoreData = results[1] as Map<String, dynamic>;

      setState(() {
        _events = activityData.map((e) => _ActivityEvent.fromJson(e)).toList();
        _showAllEvents = false;
        _safetyScore = (scoreData['score'] as num?)?.toInt() ?? 0;
        _inZonePct = (scoreData['in_zone_pct'] as num?)?.toInt() ?? 0;
        _totalUpdates = (scoreData['total_updates'] as num?)?.toInt() ?? 0;
        _inZoneUpdates = (scoreData['in_zone_updates'] as num?)?.toInt() ?? 0;
        _currentZoneName = scoreData['current_zone_name'] as String?;
        _loading = false;
      });
    } catch (_) {
      // Fallback: load from history if activity endpoint fails
      await _loadFromHistory();
    }
  }

  Future<void> _loadFromHistory() async {
    if (_selectedChildId == null) return;
    try {
      final history = (await ApiClient.instance.childHistory(_selectedChildId!))
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _events = _deriveEvents(context, history);
        _showAllEvents = false;
        _safetyScore = 0;
        _inZonePct = 0;
        _totalUpdates = history.length;
        _inZoneUpdates = 0;
        _currentZoneName = null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_ActivityEvent> _deriveEvents(
      BuildContext context, List<Map<String, dynamic>> history) {
    if (history.isEmpty) return [];
    final t = S.of(context);
    final events = <_ActivityEvent>[];
    String? lastAddress;
    int? lastBattery;

    for (int i = history.length - 1; i >= 0; i--) {
      final loc = history[i];
      final address = (loc['address'] as String?) ?? '';
      final battery = loc['battery'] as int?;
      final createdAt = DateTime.tryParse(loc['created_at'] as String? ?? '') ??
          DateTime.now();
      final timeStr = createdAt.toIso8601String();

      if (address.isNotEmpty && address != lastAddress) {
        if (lastAddress != null) {
          events.add(_ActivityEvent(
            type: 'left',
            icon: 'logout',
            title: t.leftArea,
            subtitle: lastAddress,
            time: timeStr,
          ));
        }
        events.add(_ActivityEvent(
          type: 'arrived',
          icon: 'check_circle',
          title: t.arrivedAtLocation,
          subtitle: address,
          time: timeStr,
        ));
        lastAddress = address;
      }

      if (battery != null && lastBattery != null) {
        if (battery > lastBattery + 5) {
          events.add(_ActivityEvent(
            type: 'charging',
            icon: 'bolt',
            title: t.phoneCharging,
            subtitle: t.batteryReached(battery),
            time: timeStr,
          ));
        } else if (battery < lastBattery - 20) {
          events.add(_ActivityEvent(
            type: 'battery_low',
            icon: 'battery_alert',
            title: t.batteryLow,
            subtitle: t.batteryDropped(battery),
            time: timeStr,
          ));
        }
      }
      lastBattery = battery;
    }

    if (events.isEmpty && history.isNotEmpty) {
      final latest = history.first;
      final addr = (latest['address'] as String?) ?? '';
      final bat = latest['battery'] as int?;
      final createdAt =
          DateTime.tryParse(latest['created_at'] as String? ?? '') ??
              DateTime.now();
      events.add(_ActivityEvent(
        type: 'current',
        icon: 'location_on',
        title: t.currentLocationTitle,
        subtitle: addr.isEmpty ? t.locationShared : addr,
        time: createdAt.toIso8601String(),
      ));
      if (bat != null) {
        events.add(_ActivityEvent(
          type: 'battery',
          icon: 'battery_std',
          title: t.batteryStatus,
          subtitle: t.batteryAt(bat),
          time: createdAt.toIso8601String(),
        ));
      }
    }

    return events.reversed.toList();
  }

  String get _childName {
    if (_selectedChildId == null) return 'Child';
    final child = _children.firstWhere(
      (c) => c['id'] == _selectedChildId,
      orElse: () => {'display_name': 'Child', 'username': 'child'},
    );
    return ((child['display_name'] as String?)?.isNotEmpty ?? false)
        ? child['display_name'] as String
        : child['username'] as String;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(selectedChildIdProvider, (previous, next) {
      if (!mounted || next == null || next == _selectedChildId) return;
      if (_children.any((child) => child['id'] == next)) {
        _setSelectedChild(next, syncProvider: false);
      }
    });
    final t = S.of(context);
    final session = ref.watch(sessionProvider);
    final visibleEvents =
        _showAllEvents ? _events : _events.take(_activityPreviewLimit).toList();
    final hasMoreEvents = _events.length > _activityPreviewLimit;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
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
              trailing: GearButton(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
            if (_children.length > 1)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _children.length,
                  itemBuilder: (_, i) {
                    final c = _children[i];
                    final id = c['id'] as int;
                    final name =
                        ((c['display_name'] as String?)?.isNotEmpty ?? false)
                            ? c['display_name'] as String
                            : c['username'] as String;
                    final selected = id == _selectedChildId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(name),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => _setSelectedChild(id),
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _children.isEmpty
                      ? Center(
                          child: Text(t.addChildToSeeActivity,
                              style:
                                  const TextStyle(color: AppColors.textMuted)))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            children: [
                              // Title row
                              Row(
                                children: [
                                  Text(
                                    t.activity,
                                    style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimaryLight),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      t.today,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Activity events card
                              if (_events.isEmpty)
                                AppCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.history,
                                            size: 48,
                                            color:
                                                AppColors.textSecondaryLight),
                                        const SizedBox(height: 12),
                                        Text(
                                          t.noActivityYet(_childName),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color:
                                                  AppColors.textSecondaryLight),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                AppCard(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: visibleEvents
                                        .asMap()
                                        .entries
                                        .expand((entry) => [
                                              _ActivityRow(
                                                event: entry.value,
                                              ),
                                              if (entry.key <
                                                  visibleEvents.length - 1)
                                                const Divider(
                                                  height: 1,
                                                  indent: 20,
                                                  endIndent: 20,
                                                  color: AppColors.dividerLight,
                                                ),
                                            ])
                                        .toList(),
                                  ),
                                ),
                              if (hasMoreEvents && !_showAllEvents)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Center(
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() => _showAllEvents = true);
                                      },
                                      child: const Text('More'),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 22),

                              // Safe Zones header
                              Row(
                                children: [
                                  Text(
                                    t.safeZones,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () => Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ZoneEditScreen()),
                                        )
                                        .then((_) => ref
                                            .read(safeZonesProvider.notifier)
                                            .load()),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.add,
                                            color: AppColors.primary, size: 18),
                                        const SizedBox(width: 4),
                                        Text(t.addNew,
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Safe zones list
                              ref.watch(safeZonesProvider).when(
                                    data: (zones) => zones.isEmpty
                                        ? Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              child: Text(t.noSafeZonesYet,
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.textMuted)),
                                            ),
                                          )
                                        : Column(
                                            children: zones
                                                .map((zone) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 12),
                                                      child: _SafeZoneCard(
                                                        zone: zone,
                                                        onEdit: () => Navigator
                                                                .of(context)
                                                            .push(
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      ZoneEditScreen(
                                                                          zone:
                                                                              zone)),
                                                            )
                                                            .then((_) => ref
                                                                .read(safeZonesProvider
                                                                    .notifier)
                                                                .load()),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                    loading: () => const Center(
                                        child: CircularProgressIndicator()),
                                    error: (e, _) => Center(
                                      child: Text(
                                        t.failedGeneric(e.toString()),
                                      ),
                                    ),
                                  ),

                              const SizedBox(height: 16),

                              // Daily Safety Score card
                              _SafetyScoreCard(
                                score: _safetyScore,
                                inZonePct: _inZonePct,
                                totalUpdates: _totalUpdates,
                                inZoneUpdates: _inZoneUpdates,
                                currentZoneName: _currentZoneName,
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityEvent {
  _ActivityEvent({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.zoneName,
  });

  final String type;
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final String? zoneName;

  factory _ActivityEvent.fromJson(Map<String, dynamic> j) => _ActivityEvent(
        type: (j['type'] as String?) ?? 'unknown',
        icon: (j['icon'] as String?) ?? 'location_on',
        title: (j['title'] as String?) ?? '',
        subtitle: (j['subtitle'] as String?) ?? '',
        time: (j['time'] as String?) ?? '',
        zoneName: j['zone_name'] as String?,
      );

  IconData get iconData {
    switch (icon) {
      case 'check_circle':
        return Icons.check_circle;
      case 'logout':
        return Icons.logout_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'battery_alert':
        return Icons.battery_alert;
      case 'battery_std':
        return Icons.battery_std;
      case 'location_on':
        return Icons.location_on;
      default:
        return Icons.circle;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'arrived':
        return AppColors.success;
      case 'left':
        return AppColors.warning;
      case 'charging':
        return AppColors.success;
      case 'battery_low':
        return AppColors.danger;
      case 'moved':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  String formattedTime(BuildContext context) {
    final dt = DateTime.tryParse(time);
    if (dt == null) return time;
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(dt.toLocal()),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.event});
  final _ActivityEvent event;

  String _localizedTitle(BuildContext context, _ActivityEvent event) {
    final t = S.of(context);
    switch (event.type) {
      case 'left':
        return t.leftArea;
      case 'arrived':
        return t.arrivedAtLocation;
      case 'charging':
        return t.phoneCharging;
      case 'battery_low':
        return t.batteryLow;
      case 'current':
        return t.currentLocationTitle;
      case 'battery':
        return t.batteryStatus;
      default:
        return event.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: event.iconColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(event.iconData, color: event.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_localizedTitle(context, event),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                if ((event.zoneName?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t.zone(event.zoneName!),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(event.subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondaryLight, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(event.formattedTime(context),
              style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SafeZoneCard extends StatelessWidget {
  const _SafeZoneCard({required this.zone, required this.onEdit});
  final SafeZone zone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final scheduleSummary = !zone.active
        ? t.disabled
        : zone.isAlwaysActive
            ? t.always
            : zone.activeDays.map((day) {
                return switch (day) {
                  1 => t.mon,
                  2 => t.tue,
                  3 => t.wed,
                  4 => t.thu,
                  5 => t.fri,
                  6 => t.sat,
                  7 => t.sun,
                  _ => day.toString(),
                };
              }).join(', ');
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(
                  height: 110,
                  color: const Color(0xFFD5E8C8),
                  child: AbsorbPointer(
                    child: AdaptiveMap(
                      latitude: zone.lat,
                      longitude: zone.lng,
                      children: [
                        ChildLocation(
                          name: zone.name,
                          lat: zone.lat,
                          lng: zone.lng,
                          address: zone.name,
                          battery: 0,
                          updatedAt: zone.createdAt ?? DateTime.now(),
                          active: zone.active,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: StatusBadge(
                    text: zone.isActiveToday
                        ? t.activeToday
                        : zone.active
                            ? t.inactiveToday
                            : t.disabled,
                    color: zone.isActiveToday
                        ? AppColors.success
                        : zone.active
                            ? AppColors.warning
                            : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${zone.radius.toInt()} m \u00b7 $scheduleSummary',
                          style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(t.editZone,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyScoreCard extends StatelessWidget {
  const _SafetyScoreCard({
    required this.score,
    required this.inZonePct,
    required this.totalUpdates,
    required this.inZoneUpdates,
    required this.currentZoneName,
  });
  final int score;
  final int inZonePct;
  final int totalUpdates;
  final int inZoneUpdates;
  final String? currentZoneName;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final color = score >= 80
        ? AppColors.success
        : score >= 50
            ? AppColors.warning
            : AppColors.danger;
    return AppCard(
      child: Row(
        children: [
          // Score ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: score / 100.0,
                    strokeWidth: 8,
                    backgroundColor: AppColors.dividerLight,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.dailySafetyScore,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalUpdates == 0
                      ? t.noLocationUpdatesYet
                      : t.safetyScoreDetails(inZoneUpdates, totalUpdates),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentZoneName != null
                      ? '${t.coverage(inZonePct)} \u00b7 ${t.currentZone(currentZoneName!)}'
                      : t.coverage(inZonePct),
                  style: const TextStyle(
                    fontSize: 13,
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
