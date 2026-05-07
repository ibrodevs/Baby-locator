import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';
import 'package:path_provider/path_provider.dart';

/// Full-screen red SOS alert shown on the parent's device when a child
/// triggers SOS. Plays a loud alarm sound and pulses the screen.
class SosAlertScreen extends StatefulWidget {
  const SosAlertScreen({
    super.key,
    required this.childName,
    this.message,
  });

  final String childName;
  final String? message;

  @override
  State<SosAlertScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosAlertScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _playAlarm();
  }

  Future<void> _playAlarm() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      final path = await _ensureAlarmFile();
      await _player.play(DeviceFileSource(path));
    } catch (_) {}
  }

  static String? _cachedPath;

  Future<String> _ensureAlarmFile() async {
    if (_cachedPath != null && await File(_cachedPath!).exists()) {
      return _cachedPath!;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sos_alarm.wav');
    await file.writeAsBytes(_buildAlarmWave(), flush: true);
    _cachedPath = file.path;
    return file.path;
  }

  Uint8List _buildAlarmWave() {
    const sampleRate = 44100;
    const seconds = 3;
    const totalSamples = sampleRate * seconds;
    final data = ByteData(44 + totalSamples * 2);

    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        data.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    const dataLength = totalSamples * 2;
    writeString(0, 'RIFF');
    data.setUint32(4, 36 + dataLength, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    writeString(36, 'data');
    data.setUint32(40, dataLength, Endian.little);

    var offset = 44;
    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      // Siren: alternating between two frequencies
      final freq = (t % 1.0 < 0.5) ? 800.0 : 1200.0;
      final sample = math.sin(2 * math.pi * freq * t) * 0.85;
      data.setInt16(offset, (sample * 32767).round(), Endian.little);
      offset += 2;
    }
    return data.buffer.asUint8List();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final value = _pulseController.value;
            final bgColor = Color.lerp(
              const Color(0xFFDC2626),
              const Color(0xFF7F1D1D),
              value,
            )!;
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: bgColor,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Pulsing SOS icon
                    Transform.scale(
                      scale: 1.0 + value * 0.15,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      t.sos,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.childName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        widget.message ?? t.sosNeedsHelpFallback,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(flex: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFDC2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            t.okAction,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
