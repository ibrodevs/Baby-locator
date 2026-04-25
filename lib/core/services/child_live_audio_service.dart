import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'child_webrtc_service.dart';

/// Coordinates child-side live audio on the main Flutter isolate.
///
/// `flutter_webrtc` microphone capture is unreliable in the background-service
/// isolate on Android, so the foreground service relays commands and this
/// service starts/stops WebRTC from the normal app isolate instead.
class ChildLiveAudioService {
  ChildLiveAudioService._();

  static final ChildLiveAudioService instance = ChildLiveAudioService._();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  final ChildWebRTCService _webrtc = ChildWebRTCService();

  StreamSubscription<Map<String, dynamic>?>? _startSub;
  StreamSubscription<Map<String, dynamic>?>? _stopSub;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _startSub = _service.on('webrtc_monitor_start_ui').listen((data) async {
      final sessionToken = data?['session_token'] as String? ?? '';
      if (sessionToken.isEmpty) return;
      try {
        await _webrtc.startMonitoring(sessionToken);
      } catch (e) {
        debugPrint('[ChildLiveAudio] start failed: $e');
      }
    });

    _stopSub = _service.on('webrtc_monitor_stop_ui').listen((_) async {
      try {
        await _webrtc.stopMonitoring();
      } catch (e) {
        debugPrint('[ChildLiveAudio] stop failed: $e');
      }
    });
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;

    await _startSub?.cancel();
    _startSub = null;
    await _stopSub?.cancel();
    _stopSub = null;

    try {
      await _webrtc.stopMonitoring();
    } catch (_) {}
  }
}
