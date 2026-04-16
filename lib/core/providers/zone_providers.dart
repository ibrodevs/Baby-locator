import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

class SafeZone {
  static const String scheduleAlways = 'always';
  static const String scheduleDays = 'days';
  static const Map<int, String> weekdayShortLabels = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };
  static const Map<int, String> weekdayFullLabels = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  SafeZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radius,
    required this.active,
    required this.scheduleType,
    required this.activeDays,
    this.createdAt,
  });

  final int id;
  final String name;
  final double lat;
  final double lng;
  final double radius;
  final bool active;
  final String scheduleType;
  final List<int> activeDays;
  final DateTime? createdAt;

  factory SafeZone.fromJson(Map<String, dynamic> j) => SafeZone(
        id: j['id'] as int,
        name: j['name'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        radius: (j['radius'] as num).toDouble(),
        active: (j['active'] as bool?) ?? true,
        scheduleType: (j['schedule_type'] as String?) ?? scheduleAlways,
        activeDays: ((j['active_days'] as List<dynamic>?) ?? const [])
            .map((day) => (day as num).toInt())
            .toList()
          ..sort(),
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
      );

  bool get isAlwaysActive => scheduleType == scheduleAlways;

  bool isActiveOn(DateTime date) {
    if (!active) return false;
    if (isAlwaysActive) return true;
    return activeDays.contains(date.weekday);
  }

  bool get isActiveToday => isActiveOn(DateTime.now());

  String get scheduleSummary {
    if (!active) return 'Disabled';
    if (isAlwaysActive) return 'Always active';
    if (activeDays.isEmpty) return 'No days selected';
    final labels = activeDays
        .map((day) => weekdayShortLabels[day] ?? day.toString())
        .join(', ');
    return 'Active: $labels';
  }
}

class SafeZonesNotifier extends StateNotifier<AsyncValue<List<SafeZone>>> {
  SafeZonesNotifier() : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await ApiClient.instance.listSafeZones();
      state = AsyncValue.data(list
          .map((e) => SafeZone.fromJson(e as Map<String, dynamic>))
          .toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addZone({
    required String name,
    required double lat,
    required double lng,
    required double radius,
    bool active = true,
    String scheduleType = SafeZone.scheduleAlways,
    List<int> activeDays = const [],
  }) async {
    try {
      await ApiClient.instance.createSafeZone(
        name: name,
        lat: lat,
        lng: lng,
        radius: radius,
        active: active,
        scheduleType: scheduleType,
        activeDays: activeDays,
      );
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateZone(
    int id, {
    String? name,
    double? lat,
    double? lng,
    double? radius,
    bool? active,
    String? scheduleType,
    List<int>? activeDays,
  }) async {
    try {
      await ApiClient.instance.updateSafeZone(
        id,
        name: name,
        lat: lat,
        lng: lng,
        radius: radius,
        active: active,
        scheduleType: scheduleType,
        activeDays: activeDays,
      );
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteZone(int id) async {
    try {
      await ApiClient.instance.deleteSafeZone(id);
      await load();
    } catch (e) {
      rethrow;
    }
  }
}

final safeZonesProvider =
    StateNotifierProvider<SafeZonesNotifier, AsyncValue<List<SafeZone>>>(
  (ref) => SafeZonesNotifier()..load(),
);
