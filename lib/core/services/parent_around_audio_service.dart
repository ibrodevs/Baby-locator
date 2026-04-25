import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'api_client.dart';

/// Reliable parent-side "Around" audio via short uploaded clips.
class ParentAroundAudioService {
  final AudioPlayer _player = AudioPlayer();
  final Queue<File> _pendingFiles = Queue<File>();

  StreamSubscription<void>? _playerCompleteSub;
  Timer? _pollTimer;
  Timer? _connectWatchdog;

  bool _isListening = false;
  bool _stopping = false;
  bool _fetchingClip = false;
  bool _playing = false;
  bool _audioStartedNotified = false;

  int? _childId;
  String? _sessionToken;
  int _lastClipId = 0;

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
    _fetchingClip = false;
    _playing = false;
    _audioStartedNotified = false;
    _childId = childId;
    _lastClipId = 0;

    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      _playerCompleteSub ??= _player.onPlayerComplete.listen((_) {
        unawaited(_handlePlaybackComplete());
      });

      onStatus?.call('Подключаемся к телефону ребёнка...');
      final response = await ApiClient.instance.startAround(childId);
      final sessionToken = _extractSessionToken(response);
      if (sessionToken == null || sessionToken.isEmpty) {
        onError?.call('Не удалось запустить прослушивание вокруг ребёнка.');
        await stopListening();
        return;
      }

      _sessionToken = sessionToken;
      onStatus?.call('Ждём первый аудиофрагмент...');

      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 350),
        (_) => _pollLatestClip(),
      );
      unawaited(_pollLatestClip());

      _connectWatchdog = Timer(const Duration(seconds: 6), () {
        if (!_isListening || _audioStartedNotified) return;
        onStatus?.call(
          'Телефон ребёнка просыпается и готовит микрофон. '
          'Это может занять до 20 секунд.',
        );
        _connectWatchdog = Timer(const Duration(seconds: 18), () {
          if (!_isListening || _audioStartedNotified) return;
          onError?.call(
            'От телефона ребёнка пока не пришёл звук. Проверьте интернет, '
            'разрешение на микрофон и фоновую работу приложения на его устройстве.',
          );
          unawaited(stopListening());
        });
      });
    } catch (e) {
      debugPrint('[ParentAroundAudio] startListening error: $e');
      onError?.call('Сбой запуска прослушивания: $e');
      await stopListening();
    }
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

  Future<void> _pollLatestClip() async {
    if (!_isListening || _fetchingClip) return;
    final childId = _childId;
    final sessionToken = _sessionToken;
    if (childId == null || sessionToken == null || sessionToken.isEmpty) return;

    _fetchingClip = true;
    try {
      final clip = await ApiClient.instance.latestAroundAudio(
        childId,
        sessionToken: sessionToken,
        afterId: _lastClipId > 0 ? _lastClipId : null,
      );
      if (!_isListening || clip == null) return;

      final clipId = clip['id'] as int?;
      if (clipId == null || clipId <= _lastClipId) return;

      final bytes = await ApiClient.instance.downloadAroundAudio(clipId);
      if (!_isListening) return;

      final file = await _writeClipToTempFile(clipId, bytes);
      _lastClipId = clipId;
      _pendingFiles.add(file);

      if (!_audioStartedNotified) {
        _audioStartedNotified = true;
        _connectWatchdog?.cancel();
        _connectWatchdog = null;
        onAudioStarted?.call();
        onStatus?.call('Слушаем окружение рядом с ребёнком...');
      }

      unawaited(_playNextIfIdle());
    } catch (e) {
      debugPrint('[ParentAroundAudio] poll error: $e');
    } finally {
      _fetchingClip = false;
    }
  }

  Future<File> _writeClipToTempFile(int clipId, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/around_parent_${_sessionToken ?? 'session'}_$clipId.m4a',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _playNextIfIdle() async {
    if (_playing || !_isListening || _pendingFiles.isEmpty) return;
    final file = _pendingFiles.first;
    _playing = true;
    try {
      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      debugPrint('[ParentAroundAudio] play error: $e');
      _playing = false;
      _pendingFiles.removeFirst();
      await _deleteFileQuietly(file);
      if (_isListening) {
        unawaited(_playNextIfIdle());
      }
    }
  }

  Future<void> _handlePlaybackComplete() async {
    if (_pendingFiles.isNotEmpty) {
      final finished = _pendingFiles.removeFirst();
      await _deleteFileQuietly(finished);
    }
    _playing = false;
    if (_isListening) {
      unawaited(_playNextIfIdle());
    }
  }

  Future<void> stopListening() async {
    if (_stopping) return;
    _stopping = true;

    final childId = _childId;
    final sessionToken = _sessionToken;

    _isListening = false;
    _fetchingClip = false;
    _audioStartedNotified = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    _connectWatchdog?.cancel();
    _connectWatchdog = null;

    try {
      await _player.stop();
    } catch (_) {}
    _playing = false;

    while (_pendingFiles.isNotEmpty) {
      final file = _pendingFiles.removeFirst();
      await _deleteFileQuietly(file);
    }

    _lastClipId = 0;
    _childId = null;
    _sessionToken = null;

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
    await _playerCompleteSub?.cancel();
    _playerCompleteSub = null;
    await _player.dispose();
  }

  Future<void> _deleteFileQuietly(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
