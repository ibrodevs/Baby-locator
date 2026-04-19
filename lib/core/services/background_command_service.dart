import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'api_client.dart';

bool _backgroundServiceConfigured = false;

/// Initialises and configures the background service.
/// Call once from main() before runApp.
Future<void> initBackgroundCommandService() async {
  if (_backgroundServiceConfigured) return;
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onStart,
      autoStart: false,
      isForegroundMode: true,
      autoStartOnBoot: true,
      foregroundServiceNotificationId: 8888,
      initialNotificationTitle: 'Kid Security',
      initialNotificationContent: 'Геолокация и батарея ребёнка передаются',
      foregroundServiceTypes: [
        AndroidForegroundType.location,
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
  _backgroundServiceConfigured = true;
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

Future<void> wakeChildBackgroundService() async {
  await initBackgroundCommandService();
  await startChildBackgroundService();
  await Future<void>.delayed(const Duration(milliseconds: 500));
  FlutterBackgroundService().invoke('pollNow');
}

Future<void> stopChildBackgroundService() async {
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (!isRunning) return;
  service.invoke('stop');
}

/// Helper to maximize device volume from the UI isolate.
/// Works via native Android MethodChannel.
class VolumeHelper {
  static const _channel = MethodChannel('kid_security/volume');

  static Future<void> maximize() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('maximizeVolume');
    } catch (_) {}
  }

  static Future<void> restore() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('restoreVolume');
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Background isolate handler — runs independently of the Flutter UI.
// ---------------------------------------------------------------------------

class _BackgroundCommandHandler {
  _BackgroundCommandHandler(this._service);

  static const _locationHeartbeat = Duration(minutes: 2);
  static const _deviceStatsInterval = Duration(minutes: 5);
  static const _minimumMovementMeters = 15.0;
  static const _maximumQuietPeriod = Duration(minutes: 10);

  final ServiceInstance _service;

  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  final Battery _battery = Battery();

  Timer? _pollTimer;
  Timer? _telemetryTimer;
  Timer? _deviceStatsTimer;
  Timer? _alarmStopTimer;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<BatteryState>? _batterySub;
  bool _polling = false;
  bool _capturingAround = false;
  bool _locationPushInFlight = false;
  bool _deviceStatsSyncInFlight = false;
  String? _alarmFilePath;
  String? _activeAroundSession;
  bool _alarmPlaying = false;
  Position? _lastPosition;
  int? _batteryLevel;
  BatteryState _batteryState = BatteryState.unknown;
  DateTime? _lastLocationPushAt;
  double? _lastPushedLat;
  double? _lastPushedLng;
  int? _lastPushedBattery;

  Future<void> start() async {
    // Load the auth token so ApiClient can authenticate.
    await ApiClient.instance.loadToken();

    await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
    await _ensureAlarmFile();
    await _startTelemetry();

    // Listen for stop command from the main isolate.
    _service.on('stop').listen((_) async {
      await _cleanup();
      await _service.stopSelf();
    });

    _service.on('pollNow').listen((_) async {
      await _pollCommands();
    });

    // Listen for stop-alarm command from the main isolate (parent triggered).
    _service.on('stopAlarm').listen((_) async {
      await _stopAlarm();
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
    _telemetryTimer?.cancel();
    _deviceStatsTimer?.cancel();
    _alarmStopTimer?.cancel();
    await _positionSub?.cancel();
    await _batterySub?.cancel();
    await _alarmPlayer.stop();
    await _stopAroundSession();
  }

  Future<void> _startTelemetry() async {
    await _refreshBattery();
    _batterySub?.cancel();
    _batterySub = _battery.onBatteryStateChanged.listen((state) async {
      _batteryState = state;
      await _refreshBattery();
      if (_lastPosition != null) {
        unawaited(
          _pushLocationSnapshot(
            _lastPosition!,
            force: true,
          ),
        );
      } else {
        unawaited(_syncBasicDeviceStats());
      }
    });

    await _ensureLocationStream();
    await _captureAndShareCurrentLocation(force: true);
    await _syncBasicDeviceStats();

    _telemetryTimer = Timer.periodic(
      _locationHeartbeat,
      (_) => unawaited(_captureAndShareCurrentLocation(force: true)),
    );
    _deviceStatsTimer = Timer.periodic(
      _deviceStatsInterval,
      (_) => unawaited(_syncBasicDeviceStats()),
    );
  }

  Future<void> _refreshBattery() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
    } catch (_) {}
    try {
      _batteryState = await _battery.batteryState;
    } catch (_) {}
  }

  Future<void> _ensureLocationStream() async {
    if (_positionSub != null) return;

    final permission = await _locationPermission();
    if (permission == null) {
      _updateTrackingNotification(
        'Геолокация недоступна: проверьте разрешение и GPS',
      );
      return;
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: _locationSettings(),
    ).listen(
      (position) {
        _lastPosition = position;
        unawaited(_pushLocationSnapshot(position));
      },
      onError: (_) async {
        await _positionSub?.cancel();
        _positionSub = null;
      },
    );
  }

  Future<void> _captureAndShareCurrentLocation({required bool force}) async {
    await _refreshBattery();
    if (_positionSub == null) {
      await _ensureLocationStream();
    }

    final permission = await _locationPermission();
    if (permission == null) {
      _updateTrackingNotification(
        'Геолокация недоступна: проверьте разрешение и GPS',
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      _lastPosition = position;
      await _pushLocationSnapshot(position, force: force);
    } catch (_) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _lastPosition = lastKnown;
        await _pushLocationSnapshot(lastKnown, force: force);
      }
    }
  }

  Future<LocationPermission?> _locationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return permission;
  }

  LocationSettings _locationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
        intervalDuration: const Duration(seconds: 30),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Kid Security',
          notificationText: 'Геолокация ребёнка передаётся родителю',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }

    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 15,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
    );
  }

  Future<void> _pushLocationSnapshot(
    Position position, {
    bool force = false,
  }) async {
    if (_locationPushInFlight) return;

    final now = DateTime.now();
    final batteryChanged = _batteryLevel != _lastPushedBattery;
    final movedEnough = _lastPushedLat == null ||
        _lastPushedLng == null ||
        Geolocator.distanceBetween(
              _lastPushedLat!,
              _lastPushedLng!,
              position.latitude,
              position.longitude,
            ) >=
            _minimumMovementMeters;
    final quietTooLong = _lastLocationPushAt == null ||
        now.difference(_lastLocationPushAt!) >= _maximumQuietPeriod;

    if (!force && !batteryChanged && !movedEnough && !quietTooLong) {
      return;
    }

    _locationPushInFlight = true;
    try {
      await ApiClient.instance.shareLocation(
        lat: position.latitude,
        lng: position.longitude,
        address: _formatCoordinates(position),
        battery: _batteryLevel,
        active: true,
      );

      _lastLocationPushAt = now;
      _lastPushedLat = position.latitude;
      _lastPushedLng = position.longitude;
      _lastPushedBattery = _batteryLevel;

      final batteryText = _batteryLevel != null ? ' • ${_batteryLevel!}%' : '';
      _updateTrackingNotification(
        'Геолокация активна$batteryText',
      );
    } catch (_) {
      _updateTrackingNotification('Нет сети, повторим отправку автоматически');
    } finally {
      _locationPushInFlight = false;
    }
  }

  Future<void> _syncBasicDeviceStats() async {
    if (_deviceStatsSyncInFlight) return;

    _deviceStatsSyncInFlight = true;
    try {
      await _refreshBattery();
      await ApiClient.instance.syncDeviceStats({
        'platform': Platform.operatingSystem,
        'os_version': Platform.operatingSystemVersion,
        'timezone': DateTime.now().timeZoneName,
        if (_batteryLevel != null) 'battery': _batteryLevel,
        'charging': _batteryState == BatteryState.charging ||
            _batteryState == BatteryState.full,
      });
    } catch (_) {
      // Best-effort only — we keep retrying on the timer.
    } finally {
      _deviceStatsSyncInFlight = false;
    }
  }

  String _formatCoordinates(Position position) {
    return '${position.latitude.toStringAsFixed(5)}, '
        '${position.longitude.toStringAsFixed(5)}';
  }

  void _updateTrackingNotification(String content) {
    if (_service case final AndroidServiceInstance androidService) {
      androidService.setForegroundNotificationInfo(
        title: 'Kid Security',
        content: content,
      );
    }
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
        return;
      case 'loud_stop':
        await _stopAlarm();
        return;
      case 'around_start':
        final sessionToken = payload['session_token'] as String? ?? '';
        if (sessionToken.isEmpty) {
          throw Exception('Missing around session token');
        }
        await _startAroundSession(sessionToken);
        return;
      case 'around_stop':
        final sessionToken = payload['session_token'] as String?;
        await _stopAroundSession(expectedSession: sessionToken);
        return;
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
        content: '🔊 Воспроизведение сигнала...',
      );
    }

    await _alarmPlayer.setAudioContext(
      AudioContextConfig(
        route: AudioContextConfigRoute.speaker,
        focus: AudioContextConfigFocus.duckOthers,
        respectSilence: false,
        stayAwake: true,
      ).build(),
    );

    // Maximize device volume via native channel
    await _maximizeVolumeNative();

    final filePath = await _ensureAlarmFile();
    await _alarmPlayer.stop();
    await _alarmPlayer.setVolume(1.0);
    await _alarmPlayer.play(DeviceFileSource(filePath));
    _alarmPlaying = true;
  }

  Future<void> _stopAlarm() async {
    _alarmStopTimer?.cancel();
    _alarmStopTimer = null;
    if (_alarmPlaying) {
      await _alarmPlayer.stop();
      _alarmPlaying = false;
      await _restoreVolumeNative();
      _resetNotification();
    }
  }

  /// Maximizes volume using platform channel from the background isolate.
  Future<void> _maximizeVolumeNative() async {
    if (!Platform.isAndroid) return;
    try {
      const channel = MethodChannel('kid_security/volume');
      await channel.invokeMethod('maximizeVolume');
    } catch (_) {
      // May fail in background isolate — volume control is best-effort.
    }
  }

  Future<void> _restoreVolumeNative() async {
    if (!Platform.isAndroid) return;
    try {
      const channel = MethodChannel('kid_security/volume');
      await channel.invokeMethod('restoreVolume');
    } catch (_) {}
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

    unawaited(_runAroundLoop(sessionToken));
  }

  Future<void> _stopAroundSession({String? expectedSession}) async {
    if (expectedSession != null &&
        expectedSession.isNotEmpty &&
        _activeAroundSession != expectedSession) {
      return;
    }
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

  Future<void> _runAroundLoop(String sessionToken) async {
    while (_activeAroundSession == sessionToken) {
      await _captureAroundClip();
      if (_activeAroundSession != sessionToken) break;
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
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
      await Future<void>.delayed(const Duration(seconds: 5));
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
          durationSeconds: 5,
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
      // Loud siren effect — alternating frequencies
      final freq = (t % 0.5 < 0.25) ? 880.0 : 1320.0;
      final envelope = (math.sin(math.pi * t / seconds)).abs() * 0.9 + 0.1;
      final sample = math.sin(2 * math.pi * freq * t) * envelope;
      data.setInt16(offset, (sample * 32767).round(), Endian.little);
      offset += 2;
    }
    return data.buffer.asUint8List();
  }

  void _resetNotification() {
    if (_service case final AndroidServiceInstance androidService) {
      androidService.setForegroundNotificationInfo(
        title: 'Kid Security',
        content: 'Геолокация и батарея ребёнка передаются',
      );
    }
  }
}
