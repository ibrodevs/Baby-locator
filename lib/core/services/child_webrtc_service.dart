import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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

      // 1. Capture microphone audio. Keep echo/noise/gain on for clearer speech.
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          'channelCount': 1,
          'sampleRate': 48000,
        },
        'video': false,
      });

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
          stopMonitoring();
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
    } catch (e) {
      debugPrint('[ChildWebRTC] sendSignal error: $e');
    }
  }

  Future<void> stopMonitoring() async {
    _isActive = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();
    _localStream = null;
    _sessionToken = null;
    _lastSignalId = 0;
  }
}
