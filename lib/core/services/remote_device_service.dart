import 'dart:io';

import 'package:permission_handler/permission_handler.dart' as ph;

import 'background_command_service.dart';
import 'device_stats_service.dart';
import 'fcm_service.dart';
import 'location_service.dart';

/// Thin wrapper around the background foreground-service.
///
/// The actual command polling, alarm playback, and around-recording all happen
/// inside the background isolate managed by [BackgroundCommandService].
/// This class simply starts/stops the service from the UI layer and makes
/// sure the Android-specific permissions required for true background
/// tracking (ACCESS_BACKGROUND_LOCATION + battery optimization exemption)
/// are actually requested at runtime.
class RemoteDeviceService {
  RemoteDeviceService._();

  static final RemoteDeviceService instance = RemoteDeviceService._();

  final LocationService _locationService = LocationService();
  static const DeviceStatsService _deviceStats = DeviceStatsService();

  bool _started = false;

  Future<void> start({void Function(String message)? onError}) async {
    if (_started) return;
    _started = true;

    // 1. Ensure location permission is upgraded to "Always" on Android so the
    //    foreground service continues receiving updates when the screen is
    //    off / app is backgrounded. Without this the OS throttles or kills
    //    location delivery regardless of the foreground notification.
    try {
      await _locationService.requestBackgroundPermission();
    } catch (_) {}

    // 2. Microphone must be granted BEFORE starting the foreground service.
    //    The service is declared with foregroundServiceType=microphone; on
    //    Android 14+ starting it without the runtime RECORD_AUDIO permission
    //    throws SecurityException, and the "Around" feature cannot capture
    //    mic audio from a background isolate (the permission dialog cannot
    //    be shown from the background).
    try {
      final mic = await ph.Permission.microphone.status;
      if (mic.isPermanentlyDenied) {
        // Once the user picked "Don't ask again" the system dialog is a
        // no-op. Send them to Settings so they can flip RECORD_AUDIO back
        // on; otherwise every later around_start will hit
        // SecurityException inside AroundAudioRecorder and the parent
        // will sit on the listening screen forever.
        await ph.openAppSettings();
      } else if (!mic.isGranted) {
        await ph.Permission.microphone.request();
      }
    } catch (_) {}

    // 2b. Android 13+ requires runtime POST_NOTIFICATIONS for the
    //     foreground-service notification to actually show. Without it
    //     the OS still creates the service but the notification icon
    //     never appears, FCM data wake-ups become unreliable, and the
    //     "Around" command often fails to deliver.
    if (Platform.isAndroid) {
      try {
        final notif = await ph.Permission.notification.status;
        if (notif.isPermanentlyDenied) {
          await ph.openAppSettings();
        } else if (!notif.isGranted) {
          await ph.Permission.notification.request();
        }
      } catch (_) {}
    }

    // 3. Ask the user to whitelist us from battery optimization. Required on
    //    most OEMs — otherwise Doze / App Standby will kill the service after
    //    a few minutes of screen-off.
    if (Platform.isAndroid) {
      try {
        final alreadyWhitelisted =
            await _deviceStats.isIgnoringBatteryOptimizations();
        if (!alreadyWhitelisted) {
          await _deviceStats.requestIgnoreBatteryOptimizations();
        }
      } catch (_) {}
    }

    await startChildBackgroundService();

    // 3. Register FCM token so the backend can wake the service with pushes
    //    even if it gets killed by the OS.
    await FcmService.instance.registerToken();
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    await stopChildBackgroundService();
  }
}
