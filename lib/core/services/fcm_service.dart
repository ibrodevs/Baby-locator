import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'api_client.dart';

/// Top-level handler — runs even when the app is killed.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final data = message.data;
  if (data['command_type'] == 'loud') {
    await _playLoudAlarm();
  }
}

/// Plays a loud alarm for 20 seconds. Used from both foreground and background
/// FCM handlers.
Future<void> _playLoudAlarm() async {
  final player = AudioPlayer();
  try {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(1.0);

    final filePath = await _ensureAlarmFile();
    await player.play(DeviceFileSource(filePath));

    // Play for 20 seconds then stop.
    await Future<void>.delayed(const Duration(seconds: 20));
    await player.stop();
  } finally {
    await player.dispose();
  }
}

String? _cachedAlarmPath;

Future<String> _ensureAlarmFile() async {
  if (_cachedAlarmPath != null && await File(_cachedAlarmPath!).exists()) {
    return _cachedAlarmPath!;
  }
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/kid_security_alarm_fcm.wav');
  await file.writeAsBytes(_buildAlarmWave(), flush: true);
  _cachedAlarmPath = file.path;
  return file.path;
}

Uint8List _buildAlarmWave() {
  const sampleRate = 44100;
  const seconds = 2;
  const channels = 1;
  const bitsPerSample = 16;
  const totalSamples = sampleRate * seconds;
  final data = ByteData(44 + totalSamples * 2);

  void writeString(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  const byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  const blockAlign = channels * bitsPerSample ~/ 8;
  const dataLength = totalSamples * blockAlign;

  writeString(0, 'RIFF');
  data.setUint32(4, 36 + dataLength, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, byteRate, Endian.little);
  data.setUint16(32, blockAlign, Endian.little);
  data.setUint16(34, bitsPerSample, Endian.little);
  writeString(36, 'data');
  data.setUint32(40, dataLength, Endian.little);

  var offset = 44;
  for (var i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final envelope = (math.sin(math.pi * t / seconds)).abs() * 0.9 + 0.1;
    final sample = (math.sin(2 * math.pi * 880 * t) * 0.55 +
            math.sin(2 * math.pi * 1320 * t) * 0.35 +
            math.sin(2 * math.pi * 1760 * t) * 0.10) *
        envelope;
    data.setInt16(offset, (sample * 32767).round(), Endian.little);
    offset += 2;
  }
  return data.buffer.asUint8List();
}

/// Manages FCM initialization, token registration, and foreground message
/// handling.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  bool _initialized = false;

  /// Call once after Firebase.initializeApp().
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS).
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages — handle loud command directly.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Registers the current FCM token with the backend.
  /// Call after login / on app start when authenticated.
  Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiClient.instance.registerFcmToken(token);
      }
    } catch (_) {
      // Token registration is best-effort.
    }

    // Listen for token refreshes.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await ApiClient.instance.registerFcmToken(newToken);
      } catch (_) {}
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    if (data['command_type'] == 'loud') {
      _playLoudAlarm();
    }
  }
}
