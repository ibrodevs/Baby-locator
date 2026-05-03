import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:record/record.dart';

import 'app_blocking_service.dart';
import 'device_stats_service.dart';

class ChildPermissionStatusSnapshot {
  const ChildPermissionStatusSnapshot({
    required this.locationServiceEnabled,
    required this.locationPermissionGranted,
    required this.backgroundLocationGranted,
    required this.microphoneGranted,
    required this.notificationsGranted,
    required this.usageAccessGranted,
    required this.accessibilityEnabled,
    required this.batteryOptimizationDisabled,
    required this.locationPermission,
    required this.notificationStatus,
  });

  final bool locationServiceEnabled;
  final bool locationPermissionGranted;
  final bool backgroundLocationGranted;
  final bool microphoneGranted;
  final bool notificationsGranted;
  final bool usageAccessGranted;
  final bool accessibilityEnabled;
  final bool batteryOptimizationDisabled;
  final LocationPermission locationPermission;
  final AuthorizationStatus notificationStatus;

  Map<String, dynamic> toSyncJson() => {
        'location_service_enabled': locationServiceEnabled,
        'location_permission_granted': locationPermissionGranted,
        'background_location_granted': backgroundLocationGranted,
        'microphone_granted': microphoneGranted,
        'notifications_granted': notificationsGranted,
        'usage_access_granted': usageAccessGranted,
        'accessibility_enabled': accessibilityEnabled,
        'battery_optimization_disabled': batteryOptimizationDisabled,
      };
}

class ChildPermissionStatusService {
  const ChildPermissionStatusService();

  Future<ChildPermissionStatusSnapshot> read() async {
    final locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    final locationPermission = await Geolocator.checkPermission();
    final locationPermissionGranted =
        locationPermission == LocationPermission.always ||
            locationPermission == LocationPermission.whileInUse;

    final recorder = AudioRecorder();
    bool microphoneGranted = false;
    try {
      microphoneGranted = await recorder.hasPermission();
    } finally {
      await recorder.dispose();
    }

    final notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();
    final notificationsGranted = notificationSettings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        notificationSettings.authorizationStatus ==
            AuthorizationStatus.provisional;

    var usageAccessGranted = false;
    var accessibilityEnabled = false;
    var batteryOptimizationDisabled = true;
    var backgroundLocationGranted = false;

    if (!kIsWeb && Platform.isAndroid) {
      const deviceStats = DeviceStatsService();
      final appBlocking = AppBlockingService.instance;
      try {
        final payload = await deviceStats.readPayload(
          battery: 0,
          charging: false,
          days: 1,
        );
        usageAccessGranted = payload.usageAccessGranted;
      } catch (_) {}

      try {
        accessibilityEnabled =
            await appBlocking.isAccessibilityServiceEnabled();
      } catch (_) {}

      try {
        batteryOptimizationDisabled =
            await deviceStats.isIgnoringBatteryOptimizations();
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

    return ChildPermissionStatusSnapshot(
      locationServiceEnabled: locationServiceEnabled,
      locationPermissionGranted: locationPermissionGranted,
      backgroundLocationGranted: backgroundLocationGranted,
      microphoneGranted: microphoneGranted,
      notificationsGranted: notificationsGranted,
      usageAccessGranted: usageAccessGranted,
      accessibilityEnabled: accessibilityEnabled,
      batteryOptimizationDisabled: batteryOptimizationDisabled,
      locationPermission: locationPermission,
      notificationStatus: notificationSettings.authorizationStatus,
    );
  }
}
