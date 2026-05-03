import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'child_webrtc_service.dart';

const _pendingWebrtcSessionKey = 'pending_webrtc_session_token';
const _pendingWebrtcSessionAtKey = 'pending_webrtc_session_at_ms';
// FCM-triggered listen requests older than this are considered stale and
// ignored on cold boot. 90s is generous — server-side request usually arrives
// within seconds, and the parent's monitoring watchdog times out at ~30s.
const _pendingWebrtcMaxAge = Duration(seconds: 90);

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
      await _consumeSession(sessionToken);
    });

    _stopSub = _service.on('webrtc_monitor_stop_ui').listen((_) async {
      try {
        await _webrtc.stopMonitoring();
      } catch (e) {
        debugPrint('[ChildLiveAudio] stop failed: $e');
      }
    });

    // Cold-boot recovery: if the main isolate was launched by the listen
    // full-screen-intent while the screen was locked, the background isolate
    // already handled the FCM and the `webrtc_monitor_start_ui` event fired
    // before we subscribed. Recover the pending session from disk.
    await _resumePendingSession();
  }

  Future<void> _resumePendingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_pendingWebrtcSessionKey) ?? '';
      final atMs = prefs.getInt(_pendingWebrtcSessionAtKey) ?? 0;
      if (token.isEmpty || atMs == 0) return;
      final age = DateTime.now().millisecondsSinceEpoch - atMs;
      if (age > _pendingWebrtcMaxAge.inMilliseconds) {
        await prefs.remove(_pendingWebrtcSessionKey);
        await prefs.remove(_pendingWebrtcSessionAtKey);
        return;
      }
      await _consumeSession(token);
    } catch (e) {
      debugPrint('[ChildLiveAudio] resume pending failed: $e');
    }
  }

  Future<void> _consumeSession(String sessionToken) async {
    try {
      await _webrtc.startMonitoring(sessionToken);
      // Successfully running — clear the pending flag so future cold boots
      // don't re-trigger an old session.
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_pendingWebrtcSessionKey);
      if (stored == sessionToken) {
        await prefs.remove(_pendingWebrtcSessionKey);
        await prefs.remove(_pendingWebrtcSessionAtKey);
      }
    } catch (e) {
      debugPrint('[ChildLiveAudio] start failed: $e');
    }
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
