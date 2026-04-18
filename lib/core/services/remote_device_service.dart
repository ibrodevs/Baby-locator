import 'background_command_service.dart';
import 'fcm_service.dart';

/// Thin wrapper around the background foreground-service.
///
/// The actual command polling, alarm playback, and around-recording all happen
/// inside the background isolate managed by [BackgroundCommandService].
/// This class simply starts/stops the service from the UI layer.
class RemoteDeviceService {
  RemoteDeviceService._();

  static final RemoteDeviceService instance = RemoteDeviceService._();

  bool _started = false;

  Future<void> start({void Function(String message)? onError}) async {
    if (_started) return;
    _started = true;
    await startChildBackgroundService();
    // Register FCM token so the backend can send push notifications
    // to this child device (e.g. loud command when app is killed).
    await FcmService.instance.registerToken();
  }

  Future<void> stop() async {
    _started = false;
    await stopChildBackgroundService();
  }
}
