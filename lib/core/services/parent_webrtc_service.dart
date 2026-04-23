import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'api_client.dart';

/// Runs on the parent device.
///
/// Activates monitoring via REST, then polls for signaling messages
/// (SDP offer from the child, ICE candidates) and establishes a
/// WebRTC P2P audio connection.  Audio plays through the device speaker.
class ParentWebRTCService {
  RTCPeerConnection? _peerConnection;
  Timer? _pollTimer;
  Timer? _connectWatchdog;
  MediaStream? _remoteStream;
  RTCVideoRenderer? _remoteRenderer;
  bool _isListening = false;
  bool _audioStartedNotified = false;
  String? _sessionToken;
  int? _childId;
  int _lastSignalId = 0;

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

  Future<void> _attachRemoteStream(MediaStream? stream) async {
    if (stream == null) return;
    _remoteStream = stream;
    _remoteRenderer?.srcObject = _remoteStream;

    for (final track in stream.getAudioTracks()) {
      track.enabled = true;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Helper.setSpeakerphoneOn(true);
      }
    } catch (_) {}

    if (!_audioStartedNotified) {
      _audioStartedNotified = true;
      _connectWatchdog?.cancel();
      onAudioStarted?.call();
    }
  }

  /// Activate monitoring for [childId].
  Future<void> startListening({required int childId}) async {
    if (_isListening) return;
    _isListening = true;
    _audioStartedNotified = false;
    _childId = childId;
    _lastSignalId = 0;

    try {
      onStatus?.call('Устанавливаем соединение...');

      // Initialise the hidden remote renderer — needed so the WebRTC engine
      // attaches the incoming audio track to the system audio output and
      // starts playback through the device speaker on both Android and iOS.
      _remoteRenderer = RTCVideoRenderer();
      await _remoteRenderer!.initialize();

      // 1. Create WebRTC peer connection (receive-only).
      _peerConnection = await createPeerConnection(_iceServers);

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
            onStatus?.call('Подключаемся к ребёнку...');
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            onStatus?.call('Соединение установлено');
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            onAudioStopped?.call();
            stopListening();
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
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => _pollSignals(),
      );

      // 6. Watchdog — if audio hasn't started within 15s, surface a clear error
      //    instead of leaving the parent hanging on "connecting" forever.
      _connectWatchdog = Timer(const Duration(seconds: 15), () {
        if (_isListening && !_audioStartedNotified) {
          onError?.call(
            'Ребёнок не ответил. Убедитесь, что приложение на его '
            'телефоне активно и есть доступ к интернету.',
          );
          stopListening();
        }
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
        await stopListening();
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
    final token = _sessionToken;
    final childId = _childId;
    _isListening = false;
    _audioStartedNotified = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    _connectWatchdog?.cancel();
    _connectWatchdog = null;
    try {
      await _peerConnection?.close();
    } catch (_) {}
    _peerConnection = null;
    try {
      _remoteStream?.getTracks().forEach((t) => t.stop());
      await _remoteStream?.dispose();
    } catch (_) {}
    _remoteStream = null;
    try {
      _remoteRenderer?.srcObject = null;
      await _remoteRenderer?.dispose();
    } catch (_) {}
    _remoteRenderer = null;
    _sessionToken = null;
    _childId = null;
    _lastSignalId = 0;

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
