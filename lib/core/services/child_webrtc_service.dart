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

  /// Fallback used only when the backend ICE-servers endpoint fails.
  /// Production must use the backend so the child gets the same TURN
  /// relay the parent does, otherwise cellular peers can't connect.
  static const _fallbackIceServers = <String, dynamic>{
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  Future<Map<String, dynamic>> _resolveIceServers() async {
    try {
      final data = await ApiClient.instance.fetchIceServers();
      final servers = data['iceServers'];
      if (servers is List && servers.isNotEmpty) {
        return {
          'iceServers': servers,
          'sdpSemantics': 'unified-plan',
        };
      }
    } catch (e) {
      debugPrint('[ChildWebRTC] fetchIceServers failed: $e');
    }
    return _fallbackIceServers;
  }

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

      // 1. Capture microphone audio. The earlier "loud at any cost" profile
      //    (NS off, highpass off, fake stereo, +10x remote-track boost)
      //    produced exactly the помехи the user is now complaining about:
      //    constant hiss, low-frequency rumble from handling, and clipping
      //    on top of the AGC. We bias toward CLEAN ambient capture:
      //    - noiseSuppression on: kills the steady-state hiss/fan/AC noise
      //      floor that AGC was otherwise amplifying into static.
      //    - googHighpassFilter on: removes the sub-100 Hz handling rumble
      //      (pocket movement, table thump, breath-on-mic).
      //    - googTypingNoiseDetection on: drops sharp transient clicks.
      //    - echoCancellation off: parent doesn't speak back, AEC has
      //      nothing useful to do here and just adds artefacts.
      //    - autoGainControl on: still needed so quiet rooms reach an
      //      audible level; it now operates on already-cleaned signal.
      //    - mono (channelCount=1): phones have a single mic capsule;
      //      asking for stereo gave fake-stereo phase artefacts that the
      //      parent heard as a swirly, unstable image.
      try {
        _localStream = await navigator.mediaDevices.getUserMedia({
          'audio': {
            'echoCancellation': false,
            'noiseSuppression': true,
            'autoGainControl': true,
            'channelCount': 1,
            'sampleRate': 48000,
            'googHighpassFilter': true,
            'googTypingNoiseDetection': true,
            'googAudioMirroring': false,
            'googNoiseSuppression': true,
            'googNoiseSuppression2': true,
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
      final iceConfig = await _resolveIceServers();
      _peerConnection = await createPeerConnection(iceConfig);

      // 3. Add local audio tracks.
      for (final track in _localStream!.getAudioTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      // Bump the encoder above its default ~32 kbps but NOT to the previous
      // 128 kbps stereo target — for mono ambient capture 64 kbps is already
      // transparent for Opus, and the lower bitrate ceiling means cellular
      // congestion doesn't translate into audible artefacts as fast.
      try {
        final senders = await _peerConnection!.getSenders();
        for (final sender in senders) {
          if (sender.track?.kind != 'audio') continue;
          final params = sender.parameters;
          final encodings = params.encodings ?? <RTCRtpEncoding>[];
          if (encodings.isEmpty) {
            encodings.add(RTCRtpEncoding(maxBitrate: 64000));
          } else {
            for (final enc in encodings) {
              enc.maxBitrate = 64000;
            }
          }
          params.encodings = encodings;
          await sender.setParameters(params);
        }
      } catch (e) {
        debugPrint('[ChildWebRTC] setParameters failed: $e');
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
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            // Failed = ICE has given up on the current candidate pair.
            // The previous behaviour was to tear the whole session down
            // here, which is exactly why the parent observed "audio
            // worked then stopped" — every brief cell handoff or NAT
            // rebind triggered a permanent stop. Instead, try an ICE
            // restart: keep the peer connection alive, regenerate the
            // ICE candidates, send a fresh offer with iceRestart=true.
            // The parent picks it up and we resume audio without the
            // user noticing.
            Future.microtask(_attemptIceRestart);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
            // The peer connection itself has been closed — there's
            // nothing left to recover. Tear down. Defer so we don't
            // race with the native EventChannel teardown on iOS.
            Future.microtask(stopMonitoring);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            // Transient — ICE will try to recover on its own. Don't
            // touch anything; just log.
            debugPrint(
              '[ChildWebRTC] disconnected, waiting for ICE to recover',
            );
            break;
          default:
            break;
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

  Future<void> _createAndSendOffer({bool iceRestart = false}) async {
    if (_peerConnection == null) return;
    final offer = await _peerConnection!.createOffer({
      'offerToReceiveAudio': false,
      'offerToReceiveVideo': false,
      // Forces WebRTC to regenerate ICE credentials so the new offer
      // triggers a clean ICE restart on the parent side. Without this
      // flag the offer is identical to the previous one and ICE just
      // keeps using the same dead candidate pair.
      if (iceRestart) 'iceRestart': true,
    });
    final tunedSdp = _boostOpusSdp(offer.sdp);
    final tunedOffer = RTCSessionDescription(tunedSdp, offer.type);
    await _peerConnection!.setLocalDescription(tunedOffer);
    await _sendSignal('offer', {'sdp': tunedSdp});
  }

  /// Patch the Opus fmtp line for clean, low-artefact ambient audio:
  ///   * `maxaveragebitrate=64000` — plenty for mono speech+ambient at 48 kHz
  ///     and low enough to avoid cellular congestion artefacts.
  ///   * `stereo=0; sprop-stereo=0` — phones have a single mic; forcing
  ///     stereo previously produced phasing/swirling artefacts the parent
  ///     heard as помехи.
  ///   * `usedtx=0` — DTX mutes "silence" and clicks back in noisily; off.
  ///   * `cbr=0` + `useinbandfec=1` — variable bitrate plus FEC keeps
  ///     quality up over flaky cellular without dropouts.
  ///   * `maxplaybackrate=48000; sprop-maxcapturerate=48000` — keep the
  ///     full 48 kHz path so highs aren't aliased.
  static String? _boostOpusSdp(String? sdp) {
    if (sdp == null || sdp.isEmpty) return sdp;
    final lines = sdp.split('\r\n');
    final opusPayloadIds = <String>[];
    final opusRegex = RegExp(r'^a=rtpmap:(\d+)\s+opus/', caseSensitive: false);
    for (final line in lines) {
      final m = opusRegex.firstMatch(line);
      if (m != null) opusPayloadIds.add(m.group(1)!);
    }
    if (opusPayloadIds.isEmpty) return sdp;

    const desiredParams = <String, String>{
      'maxaveragebitrate': '64000',
      'stereo': '0',
      'sprop-stereo': '0',
      'usedtx': '0',
      'cbr': '0',
      'useinbandfec': '1',
      'maxplaybackrate': '48000',
      'sprop-maxcapturerate': '48000',
    };

    for (final pid in opusPayloadIds) {
      final fmtpPrefix = 'a=fmtp:$pid';
      var found = false;
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i].startsWith(fmtpPrefix)) continue;
        found = true;
        final existing = lines[i].substring(fmtpPrefix.length).trim();
        final params = <String, String>{};
        if (existing.isNotEmpty) {
          for (final pair in existing.split(';')) {
            final kv = pair.trim();
            if (kv.isEmpty) continue;
            final eq = kv.indexOf('=');
            if (eq <= 0) continue;
            params[kv.substring(0, eq).trim()] = kv.substring(eq + 1).trim();
          }
        }
        params.addAll(desiredParams);
        final rebuilt = params.entries.map((e) => '${e.key}=${e.value}').join(';');
        lines[i] = '$fmtpPrefix $rebuilt';
        break;
      }
      if (!found) {
        // Insert a fresh fmtp line right after the matching rtpmap line.
        for (var i = 0; i < lines.length; i++) {
          final m = opusRegex.firstMatch(lines[i]);
          if (m != null && m.group(1) == pid) {
            final rebuilt = desiredParams.entries
                .map((e) => '${e.key}=${e.value}')
                .join(';');
            lines.insert(i + 1, 'a=fmtp:$pid $rebuilt');
            break;
          }
        }
      }
    }
    return lines.join('\r\n');
  }

  /// Re-handshake ICE while keeping the peer connection alive. Called
  /// when WebRTC reports `Failed` (e.g. cellular handoff, NAT rebind,
  /// transient packet loss exceeding ICE consent freshness). Without
  /// this, the audio stops after the first network blip.
  bool _iceRestartInFlight = false;

  Future<void> _attemptIceRestart() async {
    if (!_isActive || _peerConnection == null) return;
    if (_iceRestartInFlight) return;
    _iceRestartInFlight = true;
    try {
      debugPrint('[ChildWebRTC] attempting ICE restart');
      await _createAndSendOffer(iceRestart: true);
    } catch (e) {
      debugPrint('[ChildWebRTC] ICE restart failed: $e');
    } finally {
      // Brief debounce so a flurry of Failed callbacks doesn't issue
      // dozens of offers back to back.
      await Future<void>.delayed(const Duration(seconds: 2));
      _iceRestartInFlight = false;
    }
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
