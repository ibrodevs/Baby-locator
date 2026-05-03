library kid_security_android_bridge;

import 'package:flutter/services.dart';

class InstalledAppInfo {
  const InstalledAppInfo({
    required this.packageName,
    required this.appName,
    required this.isSystemApp,
  });

  final String packageName;
  final String appName;
  final bool isSystemApp;

  factory InstalledAppInfo.fromMap(Map<dynamic, dynamic> map) {
    return InstalledAppInfo(
      packageName: (map['packageName'] as String?) ?? '',
      appName: (map['appName'] as String?) ?? '',
      isSystemApp: (map['isSystemApp'] as bool?) ?? false,
    );
  }
}

class KidSecurityAppBlockingBridge {
  const KidSecurityAppBlockingBridge();

  static const MethodChannel _channel =
      MethodChannel('kid_security/app_blocking');

  Future<List<InstalledAppInfo>> listInstalledApps({
    bool includeSystemApps = true,
  }) async {
    final rawApps = await _channel.invokeMethod<List<Object?>>(
      'listInstalledApps',
      {'includeSystemApps': includeSystemApps},
    );

    return (rawApps ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(
          (entry) => InstalledAppInfo.fromMap(
            Map<dynamic, dynamic>.from(entry),
          ),
        )
        .where((app) => app.packageName.isNotEmpty && app.appName.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<String>> getBlockedPackages() async {
    final packages = await _channel.invokeMethod<List<Object?>>(
      'getBlockedPackages',
    );
    return (packages ?? const <Object?>[])
        .whereType<String>()
        .where((pkg) => pkg.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<void> setBlockedPackages(List<String> packages) async {
    await _channel.invokeMethod<void>(
      'setBlockedPackages',
      {'packages': packages},
    );
  }

  Future<bool> isAccessibilityBlockingEnabled() async {
    final enabled =
        await _channel.invokeMethod<bool>('isAccessibilityBlockingEnabled');
    return enabled ?? false;
  }

  Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod<void>('openAccessibilitySettings');
  }

  Future<String?> getForegroundPackage() {
    return _channel.invokeMethod<String>('getForegroundPackage');
  }

  Future<void> goHome() async {
    await _channel.invokeMethod<void>('goHome');
  }
}

/// Native PCM capture + chunked HTTP upload, used for the parent's "Around"
/// (live ambient audio) feature on the child device. Bypasses the `record`
/// Flutter plugin, which requires an Activity binding and therefore fails
/// when invoked from the background isolate while the screen is locked.
class KidSecurityAroundRecorderBridge {
  const KidSecurityAroundRecorderBridge();

  static const MethodChannel _channel =
      MethodChannel('kid_security/around_recorder');

  Future<void> start({
    required String sessionToken,
    required String baseUrl,
    String? authHeaderValue,
  }) async {
    await _channel.invokeMethod<void>('start', {
      'sessionToken': sessionToken,
      'baseUrl': baseUrl,
      if (authHeaderValue != null) 'authHeaderValue': authHeaderValue,
    });
  }

  Future<void> stop({String? sessionToken}) async {
    await _channel.invokeMethod<void>('stop', {
      if (sessionToken != null) 'sessionToken': sessionToken,
    });
  }

  Future<bool> isRunning() async {
    final running = await _channel.invokeMethod<bool>('isRunning');
    return running ?? false;
  }
}

class KidSecurityLiveAudioBridge {
  const KidSecurityLiveAudioBridge();

  static const MethodChannel _channel =
      MethodChannel('kid_security/live_audio_player');

  Future<void> initialize({
    required int sampleRate,
    required int channels,
  }) async {
    await _channel.invokeMethod<void>('initialize', {
      'sampleRate': sampleRate,
      'channels': channels,
    });
  }

  Future<void> start() async {
    await _channel.invokeMethod<void>('start');
  }

  Future<void> appendPcm(Uint8List bytes) async {
    await _channel.invokeMethod<void>('appendPcm', {
      'bytes': bytes,
    });
  }

  Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }
}
