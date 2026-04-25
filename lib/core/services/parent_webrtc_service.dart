import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'api_client.dart';

// Audio configuration for the PARENT side (receive-only).
// We want loud playback through the loud speaker, NOT phone-call routing,
// so the parent hears every ambient sound around the child clearly.
final AndroidAudioConfiguration _parentAndroidAudio = AndroidAudioConfiguration(
  manageAudioFocus: true,
  androidAudioMode: AndroidAudioMode.inCommunication,
  androidAudioFocusMode: AndroidAudioFocusMode.gain,
  androidAudioStreamType: AndroidAudioStreamType.voiceCall,
  androidAudioAttributesUsageType:
      AndroidAudioAttributesUsageType.voiceCommunication,
  androidAudioAttributesContentType: AndroidAudioAttributesContentType.speech,
  forceHandleAudioRouting: true,
);

/// Runs on the parent device.
///
/// Activates monitoring via REST, then polls for signaling messages
/// (SDP offer from the child, ICE candidates) and establishes a
/// WebRTC P2P audio connection.  Audio plays through the device speaker.
class ParentWebRTCService {
  RTCPeerConnection? _peerConnection;
  Timer? _pollTimer;
  Timer? _connectWatchdog;
  Timer? _disconnectWatchdog;
  MediaStream? _remoteStream;
  bool _isListening = false;
  bool _audioStartedNotified = false;
  bool _stopping = false;
  String? _sessionToken;
  int? _childId;
  int _lastSignalId = 0;
  bool _receivedOffer = false;

  /// Callbacks for UI updates.
  VoidCallback? onAudioStarted;
  VoidCallback? onAudioStopped;
  void Function(String message)? onError;
  void Function(String status)? onStatus;

  bool get isListening => _isListening;
  String? get sessionToken => _sessionToken;

  /// STUN + free public TURN servers (openrelay.metered.ca).
  /// TURN is critical so peers can connect across cellular/NAT networks.
  static const _iceServers = <String, dynamic>{
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  Future<void> _configureParentAudioSession() async {
    try {
      await Helper.ensureAudioSession();
    } catch (_) {}
    try {
      if (Platform.isAndroid) {
        await Helper.setAndroidAudioConfiguration(_parentAndroidAudio);
      } else if (Platform.isIOS) {
        // remoteOnly + preferSpeakerOutput → playback via loud speaker.
        await Helper.setAppleAudioIOMode(
          AppleAudioIOMode.remoteOnly,
          preferSpeakerOutput: true,
        );
      }
    } catch (e) {
      debugPrint('[ParentWebRTC] audio config error: $e');
    }
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Helper.setSpeakerphoneOn(true);
      }
    } catch (_) {}
  }

  Future<void> _attachRemoteStream(MediaStream? stream) async {
    if (stream == null || !_isListening) return;
    _remoteStream = stream;
    _disconnectWatchdog?.cancel();
    _disconnectWatchdog = null;

    for (final track in stream.getAudioTracks()) {
      track.enabled = true;
      // Do NOT call Helper.setVolume on remote tracks: on iOS that bridges to
      // `audioTrack.source.volume = …`, but RTCAudioTrack.source is only
      // populated for *local* tracks. Touching it on a remote track crashes
      // the app with EXC_BAD_ACCESS at 0x10.
    }

    // Reapply speaker routing — on Android the audio focus can flip back to
    // the earpiece the moment the peer connection actually starts playing.
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Helper.setSpeakerphoneOn(true);
      }
    } catch (_) {}

    if (!_audioStartedNotified) {
      _audioStartedNotified = true;
      _connectWatchdog?.cancel();
      _slowDownPolling();
      onAudioStarted?.call();
    }
  }

  void _slowDownPolling() {
    // Once audio is flowing the only signaling we still need is the rare
    // ICE update + session_status=closed. Stretch the polling interval to
    // reduce battery drain.
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) => _pollSignals(),
    );
  }

  void _scheduleDisconnectTeardown({
    required Duration delay,
    required String status,
    required String error,
  }) {
    _disconnectWatchdog?.cancel();
    onStatus?.call(status);
    _disconnectWatchdog = Timer(delay, () {
      if (!_isListening || _audioStartedNotified == false) return;
      onAudioStopped?.call();
      onError?.call(error);
      Future.microtask(stopListening);
    });
  }

  /// Activate monitoring for [childId].
  Future<void> startListening({required int childId}) async {
    if (_isListening) return;
    _isListening = true;
    _audioStartedNotified = false;
    _receivedOffer = false;
    _childId = childId;
    _lastSignalId = 0;
    _disconnectWatchdog?.cancel();
    _disconnectWatchdog = null;

    try {
      onStatus?.call('Устанавливаем соединение...');

      // 1. Create WebRTC peer connection (receive-only).
      //    For audio-only sessions we deliberately do NOT create an
      //    RTCVideoRenderer — it adds an extra iOS EventChannel whose sink
      //    can dangle when the connection tears down, crashing the app at
      //    `sink(event)` (EXC_BAD_ACCESS at 0x10). Audio playback on iOS
      //    happens automatically through RTCAudioSession once a remote
      //    audio track is added to the peer connection.
      _peerConnection = await createPeerConnection(_iceServers);

      // Now it is safe to configure routing for loud-speaker playback.
      await _configureParentAudioSession();

      await _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );

      _peerConnection!.onAddStream = (MediaStream stream) {
        debugPrint('[ParentWebRTC] Received remote stream ${stream.id}');
        unawaited(_attachRemoteStream(stream));
      };

      // 2. Handle incoming audio track from the child.
      _peerConnection!.onTrack = (RTCTrackEvent event) async {
        if (event.track.kind == 'audio') {
          debugPrint('[ParentWebRTC] Received audio track from child');
          if (event.streams.isNotEmpty) {
            await _attachRemoteStream(event.streams.first);
            return;
          }
          final remoteStreams = _peerConnection?.getRemoteStreams() ?? const [];
          if (remoteStreams.isNotEmpty) {
            await _attachRemoteStream(remoteStreams.first);
          }
        }
      };

      // 3. ICE candidate handler — send via REST.
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null) {
          _sendSignal('ice_candidate', {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          });
        }
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('[ParentWebRTC] connection state: $state');
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
            _disconnectWatchdog?.cancel();
            _disconnectWatchdog = null;
            onStatus?.call('Подключаемся к ребёнку...');
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            _disconnectWatchdog?.cancel();
            _disconnectWatchdog = null;
            onStatus?.call('Соединение установлено');
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            if (!_audioStartedNotified) {
              onStatus?.call(
                _receivedOffer
                    ? 'Сигнал от телефона ребёнка получен, продолжаем подключение...'
                    : 'Ждём ответ от телефона ребёнка...',
              );
              break;
            }
            _scheduleDisconnectTeardown(
              delay: const Duration(seconds: 8),
              status: 'Связь нестабильна, пробуем восстановить звук...',
              error: 'Аудиосвязь прервалась и не восстановилась.',
            );
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            if (!_audioStartedNotified) {
              onStatus?.call(
                _receivedOffer
                    ? 'Пробуем переподключить аудиоканал...'
                    : 'Подключение заняло больше времени, продолжаем ждать...',
              );
              break;
            }
            _scheduleDisconnectTeardown(
              delay: const Duration(seconds: 4),
              status: 'Аудиоканал потерян, пробуем переподключиться...',
              error: 'Не удалось восстановить аудиосвязь.',
            );
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
            onAudioStopped?.call();
            Future.microtask(stopListening);
            break;
          default:
            break;
        }
      };

      // 4. Activate monitoring via REST — creates session + sends FCM to child
      //    and creates a polling-backed command as a fallback.
      onStatus?.call('Будим телефон ребёнка...');
      final response = await ApiClient.instance.activateMonitoring(childId);
      _sessionToken = response['session_token'] as String? ?? '';

      if (_sessionToken == null || _sessionToken!.isEmpty) {
        onError?.call('Не удалось активировать мониторинг');
        await stopListening();
        return;
      }

      // 5. Start polling for signaling messages from the child very fast
      //    so the SDP offer + ICE candidates get picked up with minimal delay.
      //    We slow this down once audio actually starts (see _slowDownPolling).
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 150),
        (_) => _pollSignals(),
      );

      // 6. Progressive watchdog — give a status update at 5s if the child has
      //    not even sent an SDP offer yet (suggests FCM not delivered or
      //    background service not running on the kid's phone), and a final
      //    error after a longer grace period so polling fallback has time.
      _connectWatchdog = Timer(const Duration(seconds: 8), () {
        if (!_isListening || _audioStartedNotified) return;
        onStatus?.call(
          'Ждём ответ от телефона ребёнка... '
          'Это может занять до 30 секунд при заблокированном экране.',
        );
        _connectWatchdog = Timer(const Duration(seconds: 22), () {
          if (_isListening && !_audioStartedNotified) {
            onError?.call(
              'Телефон ребёнка не ответил вовремя. Проверьте, что на нём '
              'открывалось приложение после входа, есть интернет, отключены '
              'жёсткие ограничения батареи, а сервер может отправлять FCM. '
              'Разрешение на микрофон тоже должно быть включено, но это не '
              'единственная возможная причина.',
            );
            stopListening();
          }
        });
      });
    } catch (e) {
      debugPrint('[ParentWebRTC] startListening error: $e');
      onError?.call('Сбой соединения: $e');
      await stopListening();
    }
  }

  Future<void> _pollSignals() async {
    if (!_isListening || _sessionToken == null) return;
    try {
      final result = await ApiClient.instance.pollSignalingMessages(
        sessionToken: _sessionToken!,
        afterId: _lastSignalId > 0 ? _lastSignalId : null,
      );

      final status = result['session_status'] as String? ?? '';
      if (status == 'closed') {
        onAudioStopped?.call();
        Future.microtask(stopListening);
        return;
      }

      final messages = result['messages'] as List<dynamic>? ?? [];
      for (final msg in messages) {
        final m = msg as Map<String, dynamic>;
        final id = m['id'] as int;
        if (id > _lastSignalId) _lastSignalId = id;

        final type = m['type'] as String;
        final payload = m['payload'] as Map<String, dynamic>;
        await _handleSignal(type, payload);
      }
    } catch (e) {
      debugPrint('[ParentWebRTC] poll error: $e');
    }
  }

  Future<void> _handleSignal(String type, Map<String, dynamic> payload) async {
    switch (type) {
      case 'offer':
        // Received SDP offer from child — create and send answer.
        _receivedOffer = true;
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(payload['sdp'] as String?, 'offer'),
        );
        final answer = await _peerConnection?.createAnswer();
        if (answer != null) {
          await _peerConnection?.setLocalDescription(answer);
          await _sendSignal('answer', {'sdp': answer.sdp});
        }
        break;

      case 'ice_candidate':
        await _peerConnection?.addCandidate(RTCIceCandidate(
          payload['candidate'] as String?,
          payload['sdpMid'] as String?,
          payload['sdpMLineIndex'] as int?,
        ));
        break;

      case 'error':
        // Child reported a fatal issue (e.g. microphone permission denied).
        // Show its human message directly and tear down the session.
        final message = (payload['message'] as String?)?.trim();
        onError?.call(
          (message != null && message.isNotEmpty)
              ? message
              : 'Не удалось включить микрофон на телефоне ребёнка.',
        );
        Future.microtask(stopListening);
        break;
    }
  }

  Future<void> _sendSignal(String type, Map<String, dynamic> payload) async {
    if (_sessionToken == null) return;
    try {
      await ApiClient.instance.sendSignalingMessage(
        sessionToken: _sessionToken!,
        type: type,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[ParentWebRTC] sendSignal error: $e');
    }
  }

  Future<void> stopListening() async {
    if (_stopping) return;
    _stopping = true;

    final token = _sessionToken;
    final childId = _childId;
    _isListening = false;
    _audioStartedNotified = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    _connectWatchdog?.cancel();
    _connectWatchdog = null;
    _disconnectWatchdog?.cancel();
    _disconnectWatchdog = null;

    final pc = _peerConnection;
    _peerConnection = null;
    if (pc != null) {
      // Detach Dart-side callbacks BEFORE close so the native EventChannel
      // can't reach into a half-disposed Dart state. This is the key fix
      // for the postEvent → sink(event) crash on iOS.
      pc.onAddStream = null;
      pc.onTrack = null;
      pc.onIceCandidate = null;
      pc.onConnectionState = null;
      pc.onIceConnectionState = null;
      pc.onSignalingState = null;
      pc.onIceGatheringState = null;
      pc.onRemoveStream = null;
      // Give the native side a tick to drain any events already dispatched
      // to the main queue before we tear down the channel.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      try {
        await pc.close();
      } catch (_) {}
    }

    try {
      _remoteStream?.getTracks().forEach((t) => t.stop());
      await _remoteStream?.dispose();
    } catch (_) {}
    _remoteStream = null;
    _sessionToken = null;
    _childId = null;
    _lastSignalId = 0;
    _receivedOffer = false;
    _stopping = false;

    // Tell the backend to close the session and notify the child.
    if (token != null && token.isNotEmpty) {
      try {
        await ApiClient.instance.deactivateMonitoring(
          childId: childId,
          sessionToken: token,
        );
      } catch (_) {}
    }
  }
}
