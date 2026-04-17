import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'api_client.dart';

/// Initialises and configures the background service.
/// Call once from main() before runApp.
Future<void> initBackgroundCommandService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onStart,
      autoStart: false,
      isForegroundMode: true,
      autoStartOnBoot: true,
      foregroundServiceNotificationId: 8888,
      initialNotificationTitle: 'Kid Security',
      initialNotificationContent: 'Защита ребёнка активна',
      foregroundServiceTypes: [
        AndroidForegroundType.microphone,
        AndroidForegroundType.mediaPlayback,
      ],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: _onStart,
      onBackground: _onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
Future<void> _onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final handler = _BackgroundCommandHandler(service);
  await handler.start();
}

/// Starts the foreground service for the child session.
/// Reads the auth token from SharedPreferences so the background isolate
/// can make authenticated API calls.
Future<void> startChildBackgroundService() async {
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (isRunning) return;
  await service.startService();
}

Future<void> stopChildBackgroundService() async {
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (!isRunning) return;
  service.invoke('stop');
}

// ---------------------------------------------------------------------------
// Background isolate handler — runs independently of the Flutter UI.
// ---------------------------------------------------------------------------

class _BackgroundCommandHandler {
  _BackgroundCommandHandler(this._service);

  final ServiceInstance _service;

  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();

  Timer? _pollTimer;
  Timer? _alarmStopTimer;
  Timer? _aroundTimer;
  bool _polling = false;
  bool _capturingAround = false;
  String? _alarmFilePath;
  String? _activeAroundSession;

  Future<void> start() async {
    // Load the auth token so ApiClient can authenticate.
    await ApiClient.instance.loadToken();

    await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
    await _ensureAlarmFile();

    // Listen for stop command from the main isolate.
    _service.on('stop').listen((_) async {
      await _cleanup();
      await _service.stopSelf();
    });

    // Start polling immediately, then every 4 seconds.
    await _pollCommands();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _pollCommands(),
    );
  }

  Future<void> _cleanup() async {
    _pollTimer?.cancel();
    _alarmStopTimer?.cancel();
    _aroundTimer?.cancel();
    await _alarmPlayer.stop();
    await _stopAroundSession();
  }

  // ---- Command polling ----

  Future<void> _pollCommands() async {
    if (_polling) return;
    _polling = true;
    try {
      final commands = await ApiClient.instance.pendingDeviceCommands();
      for (final item in commands) {
        final command = Map<String, dynamic>.from(item as Map);
        final id = command['id'] as int;
        try {
          await _handleCommand(command);
          await ApiClient.instance.completeDeviceCommand(id, success: true);
        } catch (e) {
          await ApiClient.instance.completeDeviceCommand(
            id,
            success: false,
            errorMessage: e.toString(),
          );
        }
      }
    } catch (_) {
      // Network error — will retry next cycle.
    } finally {
      _polling = false;
    }
  }

  Future<void> _handleCommand(Map<String, dynamic> command) async {
    final type = command['command_type'] as String? ?? '';
    final payload = command['payload'] is Map
        ? Map<String, dynamic>.from(command['payload'] as Map)
        : <String, dynamic>{};

    switch (type) {
      case 'loud':
        await _playAlarm();
      case 'around_start':
        final sessionToken = payload['session_token'] as String? ?? '';
        if (sessionToken.isEmpty) {
          throw Exception('Missing around session token');
        }
        await _startAroundSession(sessionToken);
      case 'around_stop':
        final sessionToken = payload['session_token'] as String?;
        await _stopAroundSession(expectedSession: sessionToken);
      default:
        throw Exception('Unsupported command type: $type');
    }
  }

  // ---- Loud alarm ----

  Future<void> _playAlarm() async {
    // Update notification to show alarm is playing.
    if (_service case final AndroidServiceInstance androidService) {
      androidService.setForegroundNotificationInfo(
        title: 'Kid Security',
        content: 'Воспроизведение сигнала...',
      );
    }

    final filePath = await _ensureAlarmFile();
    await _alarmPlayer.stop();
    await _alarmPlayer.setVolume(1.0);
    await _alarmPlayer.play(DeviceFileSource(filePath));

    _alarmStopTimer?.cancel();
    _alarmStopTimer = Timer(const Duration(seconds: 20), () async {
      await _alarmPlayer.stop();
      _resetNotification();
    });
  }

  // ---- Around (microphone) ----

  Future<void> _startAroundSession(String sessionToken) async {
    if (_activeAroundSession == sessionToken) return;
    await _stopAroundSession();

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    _activeAroundSession = sessionToken;

    if (_service case final AndroidServiceInstance androidService) {
      androidService.setForegroundNotificationInfo(
        title: 'Kid Security',
        content: 'Прослушивание окружения...',
      );
    }

    await _captureAroundClip();
    _aroundTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _captureAroundClip(),
    );
  }

  Future<void> _stopAroundSession({String? expectedSession}) async {
    if (expectedSession != null &&
        expectedSession.isNotEmpty &&
        _activeAroundSession != expectedSession) {
      return;
    }
    _aroundTimer?.cancel();
    _aroundTimer = null;
    if (await _recorder.isRecording()) {
      final path = await _recorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
    _activeAroundSession = null;
    _capturingAround = false;
    _resetNotification();
  }

  Future<void> _captureAroundClip() async {
    final sessionToken = _activeAroundSession;
    if (sessionToken == null || _capturingAround) return;
    _capturingAround = true;
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/around_${sessionToken}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      await Future<void>.delayed(const Duration(seconds: 6));
      if (_activeAroundSession != sessionToken) return;
      final recordedPath = await _recorder.stop();
      if (recordedPath == null) {
        throw Exception('Around audio recording failed');
      }
      final file = File(recordedPath);
      if (await file.exists()) {
        await ApiClient.instance.uploadAroundAudio(
          audioFile: file,
          sessionToken: sessionToken,
          durationSeconds: 6,
        );
        await file.delete();
      }
    } finally {
      _capturingAround = false;
    }
  }

  // ---- Alarm WAV generation ----

  Future<String> _ensureAlarmFile() async {
    if (_alarmFilePath != null && await File(_alarmFilePath!).exists()) {
      return _alarmFilePath!;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/kid_security_alarm.wav');
    await file.writeAsBytes(_buildAlarmWave(), flush: true);
    _alarmFilePath = file.path;
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

  void _resetNotification() {
    if (_service case final AndroidServiceInstance androidService) {
      androidService.setForegroundNotificationInfo(
        title: 'Kid Security',
        content: 'Защита ребёнка активна',
      );
    }
  }
}
