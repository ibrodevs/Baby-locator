import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:kid_security_android_bridge/kid_security_android_bridge.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBlockingService {
  AppBlockingService._();

  static final AppBlockingService instance = AppBlockingService._();
  static const _blockedAppsKey = 'blocked_apps';

  final KidSecurityAppBlockingBridge _bridge =
      const KidSecurityAppBlockingBridge();

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<List<InstalledAppInfo>> listInstalledApps({
    bool includeSystemApps = true,
  }) async {
    if (!isSupported) return const <InstalledAppInfo>[];

    final apps = await _bridge.listInstalledApps(
      includeSystemApps: includeSystemApps,
    );
    final sortedApps = apps.toList(growable: false)
      ..sort(
        (left, right) => left.appName.toLowerCase().compareTo(
              right.appName.toLowerCase(),
            ),
      );
    return sortedApps;
  }

  Future<Set<String>> loadBlockedPackages() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_blockedAppsKey) ?? const <String>[])
        .where((pkg) => pkg.trim().isNotEmpty)
        .map((pkg) => pkg.trim())
        .toSet();
  }

  Future<void> syncBlockedPackages(Iterable<String> packages) async {
    final normalized = packages
        .map((pkg) => pkg.trim())
        .where((pkg) => pkg.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_blockedAppsKey, normalized);

    if (!isSupported) return;
    await _bridge.setBlockedPackages(normalized);
  }

  Future<void> refreshNativeStateFromPrefs() async {
    if (!isSupported) return;
    await _bridge.setBlockedPackages(
      (await loadBlockedPackages()).toList(growable: false),
    );
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    if (!isSupported) return false;
    return _bridge.isAccessibilityBlockingEnabled();
  }

  Future<void> openAccessibilitySettings() async {
    if (!isSupported) return;
    await _bridge.openAccessibilitySettings();
  }

  Future<String?> getForegroundPackage() async {
    if (!isSupported) return null;
    return _bridge.getForegroundPackage();
  }

  Future<void> goHome() async {
    if (!isSupported) return;
    await _bridge.goHome();
  }
}
