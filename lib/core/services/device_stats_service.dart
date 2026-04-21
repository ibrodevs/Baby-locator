import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceStatsPayload {
  DeviceStatsPayload({
    required this.deviceName,
    required this.manufacturer,
    required this.model,
    required this.platform,
    required this.osVersion,
    required this.timezone,
    required this.battery,
    required this.charging,
    required this.usageAccessGranted,
    required this.days,
  });

  final String deviceName;
  final String manufacturer;
  final String model;
  final String platform;
  final String osVersion;
  final String timezone;
  final int? battery;
  final bool charging;
  final bool usageAccessGranted;
  final List<DeviceUsageDay> days;

  Map<String, dynamic> toJson() => {
        'device_name': deviceName,
        'manufacturer': manufacturer,
        'model': model,
        'platform': platform,
        'os_version': osVersion,
        'timezone': timezone,
        'battery': battery,
        'charging': charging,
        'usage_access_granted': usageAccessGranted,
        'days': days.map((day) => day.toJson()).toList(),
      };
}

class DeviceUsageDay {
  DeviceUsageDay({
    required this.date,
    required this.totalMinutes,
    required this.apps,
  });

  final String date;
  final int totalMinutes;
  final List<DeviceUsageApp> apps;

  Map<String, dynamic> toJson() => {
        'date': date,
        'total_minutes': totalMinutes,
        'apps': apps.map((app) => app.toJson()).toList(),
      };
}

class DeviceUsageApp {
  DeviceUsageApp({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
    this.lastUsedAt,
  });

  final String packageName;
  final String appName;
  final int usageMinutes;
  final String? lastUsedAt;

  Map<String, dynamic> toJson() => {
        'package_name': packageName,
        'app_name': appName,
        'usage_minutes': usageMinutes,
        if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      };
}

class DeviceStatsService {
  const DeviceStatsService();

  static const MethodChannel _channel =
      MethodChannel('kid_security/device_stats');

  bool get supportsUsageAccess => !kIsWeb && Platform.isAndroid;

  Future<DeviceStatsPayload> readPayload({
    required int battery,
    required bool charging,
    int days = 35,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return DeviceStatsPayload(
        deviceName: 'Unsupported device',
        manufacturer: '',
        model: '',
        platform: kIsWeb ? 'web' : Platform.operatingSystem,
        osVersion: '',
        timezone: DateTime.now().timeZoneName,
        battery: battery,
        charging: charging,
        usageAccessGranted: false,
        days: const [],
      );
    }

    final raw = await _channel.invokeMethod<dynamic>(
      'getDeviceStats',
      {'days': days},
    );
    final data =
        Map<String, dynamic>.from((raw as Map).cast<dynamic, dynamic>());
    final rawDays = (data['days'] as List<dynamic>? ?? const []);

    return DeviceStatsPayload(
      deviceName: (data['deviceName'] as String?) ?? '',
      manufacturer: (data['manufacturer'] as String?) ?? '',
      model: (data['model'] as String?) ?? '',
      platform: (data['platform'] as String?) ?? 'android',
      osVersion: (data['osVersion'] as String?) ?? '',
      timezone: (data['timezone'] as String?) ?? DateTime.now().timeZoneName,
      battery: battery,
      charging: charging,
      usageAccessGranted: (data['usageAccessGranted'] as bool?) ?? false,
      days: rawDays
          .map((entry) {
            final day = Map<String, dynamic>.from(
              (entry as Map).cast<dynamic, dynamic>(),
            );
            final rawApps = day['apps'] as List<dynamic>? ?? const [];
            return DeviceUsageDay(
              date: (day['date'] as String?) ?? '',
              totalMinutes: (day['totalMinutes'] as int?) ?? 0,
              apps: rawApps
                  .map((appEntry) {
                    final app = Map<String, dynamic>.from(
                      (appEntry as Map).cast<dynamic, dynamic>(),
                    );
                    return DeviceUsageApp(
                      packageName: (app['packageName'] as String?) ?? '',
                      appName: (app['appName'] as String?) ?? '',
                      usageMinutes: (app['usageMinutes'] as int?) ?? 0,
                      lastUsedAt: app['lastUsedAt'] as String?,
                    );
                  })
                  .where((app) =>
                      app.packageName.isNotEmpty && app.usageMinutes >= 0)
                  .toList(),
            );
          })
          .where((day) => day.date.isNotEmpty)
          .toList(),
    );
  }

  Future<void> openUsageAccessSettings() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('openUsageAccessSettings');
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final result = await _channel.invokeMethod<bool>(
      'isIgnoringBatteryOptimizations',
    );
    return result ?? false;
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
  }
}
