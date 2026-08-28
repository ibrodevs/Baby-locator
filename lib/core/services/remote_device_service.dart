import 'background_command_service.dart';
import 'fcm_service.dart';


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

  bool _started = false;

  Future<void> start({void Function(String message)? onError}) async {
    if (_started) return;
    _started = true;

    try {
      await startChildBackgroundService();
    } catch (e) {
      onError?.call(e.toString());
    }

    try {
      await FcmService.instance.registerToken();
    } catch (_) {}
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    await stopChildBackgroundService();
  }
}

