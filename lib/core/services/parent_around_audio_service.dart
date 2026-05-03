import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kid_security_android_bridge/kid_security_android_bridge.dart';

import 'api_client.dart';

/// Parent-side live audio built on a single continuous PCM stream.
class ParentAroundAudioService {
  final KidSecurityLiveAudioBridge _playerBridge =
      const KidSecurityLiveAudioBridge();

  ApiStreamResponse? _streamResponse;
  Future<void>? _streamTask;
  Timer? _connectWatchdog;
  bool _isListening = false;
  bool _stopping = false;
  bool _audioStartedNotified = false;
  int? _childId;
  String? _sessionToken;

  VoidCallback? onAudioStarted;
  VoidCallback? onAudioStopped;
  void Function(String message)? onError;
  void Function(String status)? onStatus;

  bool get isListening => _isListening;
  String? get sessionToken => _sessionToken;

  Future<void> startListening({required int childId}) async {
    if (_isListening) return;

    _isListening = true;
    _stopping = false;
    _audioStartedNotified = false;
    _childId = childId;

    try {
      onStatus?.call('Подключаемся к телефону ребёнка...');
      final response = await ApiClient.instance.startAround(childId);
      final sessionToken = _extractSessionToken(response);
      if (sessionToken == null || sessionToken.isEmpty) {
        throw StateError('Missing around session token.');
      }

      _sessionToken = sessionToken;
      onStatus?.call('Открываем непрерывный аудиоканал...');

      final liveResponse = await ApiClient.instance.openLiveAroundAudioStream(
        childId,
        sessionToken: sessionToken,
      );
      if (liveResponse.response.statusCode != 200) {
        final body = await liveResponse.response.stream.bytesToString();
        liveResponse.close();
        throw ApiException(
          liveResponse.response.statusCode,
          body.isEmpty ? 'Failed to open live audio stream' : body,
        );
      }

      _streamResponse = liveResponse;
      final sampleRate = int.tryParse(
            liveResponse.response.headers['x-audio-sample-rate'] ?? '',
          ) ??
          16000;
      final channels = int.tryParse(
            liveResponse.response.headers['x-audio-channels'] ?? '',
          ) ??
          1;

      await _playerBridge.initialize(
        sampleRate: sampleRate,
        channels: channels,
      );
      await _playerBridge.start();
      onStatus?.call('Ждём первый звук...');

      _streamTask = _consumeLiveStream(liveResponse);
      // No auto-stop watchdog. FCM delivery, Android Doze release, and a
      // foreground-service spinning up on a deeply asleep device can
      // legitimately take more than a minute on some phones, and we
      // don't want to falsely fail the session in those cases. We just
      // surface progressive status to the parent UI; the user can stop
      // listening manually if they decide it's taking too long.
      _connectWatchdog = Timer(const Duration(seconds: 15), () {
        if (!_isListening || _audioStartedNotified) return;
        onStatus?.call(
          'Будим телефон ребёнка и открываем микрофон. '
          'На заблокированном экране это может занять до минуты.',
        );
        _connectWatchdog = Timer(const Duration(seconds: 45), () {
          if (!_isListening || _audioStartedNotified) return;
          onStatus?.call(
            'Всё ещё ждём первый звук — телефон ребёнка пока не отвечает. '
            'Можете нажать «Стоп», если не хотите больше ждать.',
          );
        });
      });
    } catch (e) {
      debugPrint('[ParentAroundAudio] startListening error: $e');
      onError?.call('Сбой запуска прослушивания: $e');
      await stopListening();
    }
  }

  Future<void> _consumeLiveStream(ApiStreamResponse liveResponse) async {
    try {
      await for (final chunk in liveResponse.response.stream) {
        if (!_isListening) break;
        if (chunk.isEmpty) continue;

        final isSilence = _isAllZero(chunk);

        // Backend sends silence keep-alive frames while waiting for the
        // child to wake up. They keep nginx/proxies from idling out the
        // connection but must NOT count as "real audio arrived" — otherwise
        // the watchdog never fires and the user listens to silence forever.
        if (!isSilence && !_audioStartedNotified) {
          _audioStartedNotified = true;
          _connectWatchdog?.cancel();
          _connectWatchdog = null;
          onAudioStarted?.call();
          onStatus?.call('Слушаем окружение рядом с ребёнком...');
        }

        await _playerBridge.appendPcm(Uint8List.fromList(chunk));
      }

      if (_isListening && !_stopping) {
        onAudioStopped?.call();
        onStatus?.call('Аудиоканал завершён.');
        await stopListening();
      }
    } catch (e) {
      debugPrint('[ParentAroundAudio] live stream error: $e');
      if (_isListening && !_stopping) {
        onError?.call('Поток аудио оборвался: $e');
        await stopListening();
      }
    } finally {
      liveResponse.close();
      if (identical(_streamResponse, liveResponse)) {
        _streamResponse = null;
      }
    }
  }

  bool _isAllZero(List<int> chunk) {
    for (final byte in chunk) {
      if (byte != 0) return false;
    }
    return true;
  }

  String? _extractSessionToken(Map<String, dynamic> response) {
    final direct = response['session_token'] as String?;
    if (direct != null && direct.isNotEmpty) return direct;
    final payload = response['payload'];
    if (payload is Map) {
      final token = payload['session_token'] as String?;
      if (token != null && token.isNotEmpty) return token;
    }
    return null;
  }

  Future<void> stopListening() async {
    if (_stopping) return;
    _stopping = true;

    final childId = _childId;
    final sessionToken = _sessionToken;

    _isListening = false;
    _audioStartedNotified = false;
    _childId = null;
    _sessionToken = null;

    _connectWatchdog?.cancel();
    _connectWatchdog = null;

    try {
      _streamResponse?.close();
    } catch (_) {}
    _streamResponse = null;

    try {
      await _playerBridge.stop();
    } catch (_) {}

    if (childId != null && sessionToken != null && sessionToken.isNotEmpty) {
      try {
        await ApiClient.instance.stopAround(
          childId,
          sessionToken: sessionToken,
        );
      } catch (_) {}
    }

    _stopping = false;
  }

  Future<void> dispose() async {
    await stopListening();
    final task = _streamTask;
    _streamTask = null;
    try {
      await task;
    } catch (_) {}
  }
}
