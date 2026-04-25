import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'api_client.dart';

/// Runs on the child device.
///
/// When triggered by an FCM push, captures microphone audio and streams it
/// to the parent device via a WebRTC peer-to-peer connection.
/// Signaling (SDP/ICE exchange) happens through REST polling against the
/// Django backend — no WebSocket or Redis required.
class ChildWebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  Timer? _pollTimer;
  bool _isActive = false;
  bool _stopping = false;
  String? _sessionToken;
  int _lastSignalId = 0;

  String? get activeSessionToken => _isActive ? _sessionToken : null;
  bool get isActive => _isActive;

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

  /// Start capturing audio and signaling with the parent.
  /// Called when an FCM push with `webrtc_monitor_start` arrives,
  /// or via the background-polled RemoteDeviceCommand.
  Future<void> startMonitoring(String sessionToken) async {
    // If already running with the same session, nothing to do.
    if (_isActive && _sessionToken == sessionToken) return;
    // Different session — reset and rejoin with the new token.
    if (_isActive) {
      await stopMonitoring();
    }
    _isActive = true;
    _sessionToken = sessionToken;
    _lastSignalId = 0;

    try {
      // Ensure ApiClient has the auth token loaded (important in background).
      await ApiClient.instance.loadToken();

      // Microphone must already be granted — the background isolate cannot
      // show a system permission dialog. If it isn't, fail fast and surface
      // the reason to the parent via a signaling message so the UI stops
      // showing "connecting..." for 15 seconds.
      final micStatus = await ph.Permission.microphone.status;
      if (!micStatus.isGranted) {
        await _sendSignal('error', {
          'reason': 'microphone_permission_denied',
          'message':
              'Ребёнок не дал разрешение на микрофон. Откройте приложение '
                  'на телефоне ребёнка и разрешите доступ к микрофону.',
        });
        throw StateError('microphone_permission_denied');
      }

      // 1. Capture microphone audio. We deliberately turn echo/noise/gain
      //    OFF here — the parent wants to hear the *ambient* sounds around
      //    the child (TV, voices, traffic), not just speech. Aggressive DSP
      //    silences anything that doesn't look like a person talking right
      //    next to the phone, which is exactly the opposite of what we want.
      try {
        _localStream = await navigator.mediaDevices.getUserMedia({
          'audio': {
            'echoCancellation': false,
            'noiseSuppression': false,
            'autoGainControl': true,
            'channelCount': 1,
            'sampleRate': 48000,
          },
          'video': false,
        });
      } catch (e) {
        await _sendSignal('error', {
          'reason': 'mic_capture_failed',
          'message': 'Не удалось включить микрофон на телефоне ребёнка. '
              'Проверьте, что разрешение на микрофон активно и '
              'микрофон не используется другим приложением.',
        });
        rethrow;
      }

      // 2. Create WebRTC peer connection.
      _peerConnection = await createPeerConnection(_iceServers);

      // 3. Add local audio tracks.
      for (final track in _localStream!.getAudioTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      // 4. ICE candidate handler — send via REST.
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
        debugPrint('[ChildWebRTC] connection state: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          // Defer teardown — closing from inside the state callback races
          // with the iOS EventChannel and crashes at postEvent → sink(event).
          Future.microtask(stopMonitoring);
        }
      };

      // 5. Create and send SDP offer immediately.
      await _createAndSendOffer();

      // 6. Start polling for signals from the parent (200ms for fast setup).
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => _pollSignals(),
      );
    } catch (e) {
      debugPrint('[ChildWebRTC] startMonitoring error: $e');
      // Only send a generic error if we haven't already sent a more specific
      // one above (mic permission / mic capture). A generic signal still
      // saves the parent from sitting on a 12-second timeout.
      try {
        await _sendSignal('error', {
          'reason': 'startup_failed',
          'message': 'Соединение с микрофоном ребёнка не установилось. '
              'Попробуйте ещё раз через несколько секунд.',
        });
      } catch (_) {}
      await stopMonitoring();
      rethrow;
    }
  }

  Future<void> _createAndSendOffer() async {
    if (_peerConnection == null) return;
    final offer = await _peerConnection!.createOffer({
      'offerToReceiveAudio': false,
      'offerToReceiveVideo': false,
    });
    await _peerConnection!.setLocalDescription(offer);
    await _sendSignal('offer', {'sdp': offer.sdp});
  }

  Future<void> _pollSignals() async {
    if (!_isActive || _sessionToken == null) return;
    try {
      final result = await ApiClient.instance.pollSignalingMessages(
        sessionToken: _sessionToken!,
        afterId: _lastSignalId > 0 ? _lastSignalId : null,
      );

      final status = result['session_status'] as String? ?? '';
      if (status == 'closed') {
        await stopMonitoring();
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
      debugPrint('[ChildWebRTC] poll error: $e');
    }
  }

  Future<void> _handleSignal(String type, Map<String, dynamic> payload) async {
    switch (type) {
      case 'answer':
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(payload['sdp'] as String?, 'answer'),
        );
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
    } on ApiException catch (e) {
      if (e.statusCode == 410) {
        debugPrint('[ChildWebRTC] session already closed, stopping quietly');
        await stopMonitoring();
        return;
      }
      debugPrint('[ChildWebRTC] sendSignal error: $e');
    } catch (e) {
      debugPrint('[ChildWebRTC] sendSignal error: $e');
    }
  }

  Future<void> stopMonitoring() async {
    if (_stopping) return;
    _stopping = true;

    _isActive = false;
    _pollTimer?.cancel();
    _pollTimer = null;

    final pc = _peerConnection;
    _peerConnection = null;
    if (pc != null) {
      // Detach Dart callbacks before close so native EventChannel cannot
      // post into a half-disposed peer connection (iOS sink crash fix).
      pc.onIceCandidate = null;
      pc.onConnectionState = null;
      pc.onIceConnectionState = null;
      pc.onSignalingState = null;
      pc.onIceGatheringState = null;
      pc.onAddStream = null;
      pc.onRemoveStream = null;
      pc.onTrack = null;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      try {
        await pc.close();
      } catch (_) {}
    }

    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    _sessionToken = null;
    _lastSignalId = 0;
    _stopping = false;
  }
}
