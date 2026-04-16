import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class NotificationSettingsModel {
  const NotificationSettingsModel({
    required this.pushEnabled,
    required this.locationAlerts,
    required this.batteryAlerts,
    required this.safeZoneAlerts,
  });

  static const defaults = NotificationSettingsModel(
    pushEnabled: true,
    locationAlerts: true,
    batteryAlerts: true,
    safeZoneAlerts: true,
  );

  final bool pushEnabled;
  final bool locationAlerts;
  final bool batteryAlerts;
  final bool safeZoneAlerts;

  NotificationSettingsModel copyWith({
    bool? pushEnabled,
    bool? locationAlerts,
    bool? batteryAlerts,
    bool? safeZoneAlerts,
  }) {
    return NotificationSettingsModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      locationAlerts: locationAlerts ?? this.locationAlerts,
      batteryAlerts: batteryAlerts ?? this.batteryAlerts,
      safeZoneAlerts: safeZoneAlerts ?? this.safeZoneAlerts,
    );
  }
}

class NotificationSettingsStore {
  NotificationSettingsStore._();

  static const _pushEnabledKey = 'notifications_push_enabled';
  static const _locationAlertsKey = 'notifications_location_alerts';
  static const _batteryAlertsKey = 'notifications_battery_alerts';
  static const _safeZoneAlertsKey = 'notifications_safe_zone_alerts';

  static Future<NotificationSettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettingsModel(
      pushEnabled: prefs.getBool(_pushEnabledKey) ?? true,
      locationAlerts: prefs.getBool(_locationAlertsKey) ?? true,
      batteryAlerts: prefs.getBool(_batteryAlertsKey) ?? true,
      safeZoneAlerts: prefs.getBool(_safeZoneAlertsKey) ?? true,
    );
  }

  static Future<void> save(NotificationSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushEnabledKey, settings.pushEnabled);
    await prefs.setBool(_locationAlertsKey, settings.locationAlerts);
    await prefs.setBool(_batteryAlertsKey, settings.batteryAlerts);
    await prefs.setBool(_safeZoneAlertsKey, settings.safeZoneAlerts);
  }
}

class DeviceNotificationService {
  DeviceNotificationService._();

  static final DeviceNotificationService instance =
      DeviceNotificationService._();

  static const _androidChannelId = 'kid_security_activity_alerts';
  static const _androidChannelName = 'Kid Security Alerts';
  static const _androidChannelDescription =
      'Notifications about children activity, battery, and safe zones.';
  static const _seenEventsKey = 'notification_seen_activity_signatures';
  static const _maxStoredSignatures = 250;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationSettingsModel _settings = NotificationSettingsModel.defaults;
  Timer? _pollingTimer;
  bool _initialized = false;
  bool _baselineReady = false;
  bool _pollInFlight = false;
  int? _activeParentId;

  Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      ),
    );

    await _plugin.initialize(initializationSettings);
    _settings = await NotificationSettingsStore.load();
    _initialized = true;
  }

  Future<bool> ensurePermissions() async {
    await initialize();
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? true;
    }

    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  Future<NotificationSettingsModel> loadSettings() async {
    _settings = await NotificationSettingsStore.load();
    return _settings;
  }

  Future<void> updateSettings(NotificationSettingsModel settings) async {
    _settings = settings;
    await NotificationSettingsStore.save(settings);
    if (!settings.pushEnabled) {
      _cancelTimer();
    } else if (_activeParentId != null) {
      await syncParentSession(_activeParentId);
    }
  }

  Future<void> syncParentSession(int? parentId) async {
    await initialize();
    _settings = await NotificationSettingsStore.load();

    if (parentId == null || !_settings.pushEnabled) {
      _activeParentId = parentId;
      _cancelTimer();
      return;
    }

    final parentChanged = _activeParentId != parentId;
    _activeParentId = parentId;

    if (parentChanged || _pollingTimer == null) {
      _baselineReady = false;
      await _poll(showNotifications: false);
      _cancelTimer();
      _pollingTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _poll(showNotifications: true),
      );
    }
  }

  Future<void> refreshNow() async {
    if (_activeParentId == null) return;
    await initialize();
    _settings = await NotificationSettingsStore.load();
    if (!_settings.pushEnabled) return;
    await _poll(showNotifications: _baselineReady);
  }

  void stop() {
    _activeParentId = null;
    _cancelTimer();
  }

  void _cancelTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _poll({required bool showNotifications}) async {
    if (_pollInFlight || _activeParentId == null) return;
    _pollInFlight = true;
    try {
      final children = (await ApiClient.instance.listChildren())
          .cast<Map<String, dynamic>>();
      final seenSignatures = await _loadSeenSignatures();
      final freshSignatures = <String>{};
      final notifications = <_PendingNotification>[];

      for (final child in children) {
        final childId = child['id'] as int;
        final childName =
            ((child['display_name'] as String?)?.isNotEmpty ?? false)
                ? child['display_name'] as String
                : child['username'] as String;

        try {
          final events = (await ApiClient.instance.childActivity(childId))
              .cast<Map<String, dynamic>>();
          for (final event in events) {
            final signature = _signatureFor(childId, event);
            freshSignatures.add(signature);

            if (!showNotifications || seenSignatures.contains(signature)) {
              continue;
            }
            if (!_shouldNotify(event)) {
              continue;
            }

            notifications.add(
              _PendingNotification(
                childName: childName,
                title: event['title'] as String? ?? 'Activity update',
                subtitle: event['subtitle'] as String? ?? '',
                zoneName: event['zone_name'] as String?,
                signature: signature,
                timestamp: DateTime.tryParse(event['time'] as String? ?? ''),
              ),
            );
          }
        } catch (_) {
          // Skip one child if their activity request fails.
        }
      }

      await _saveSeenSignatures(freshSignatures.toList()..sort());
      notifications.sort((a, b) {
        final aTime = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

      for (final notification in notifications.take(5)) {
        await _showNotification(notification);
      }

      _baselineReady = true;
    } finally {
      _pollInFlight = false;
    }
  }

  bool _shouldNotify(Map<String, dynamic> event) {
    final type = (event['type'] as String?) ?? '';
    final hasZone = ((event['zone_name'] as String?)?.isNotEmpty ?? false);

    if (_settings.safeZoneAlerts &&
        hasZone &&
        (type == 'arrived' || type == 'left')) {
      return true;
    }

    if (_settings.batteryAlerts &&
        (type == 'battery_low' || type == 'battery')) {
      return true;
    }

    if (_settings.locationAlerts &&
        (type == 'moved' ||
            type == 'current' ||
            (!hasZone && type == 'arrived') ||
            (!hasZone && type == 'left'))) {
      return true;
    }

    return false;
  }

  String _signatureFor(int childId, Map<String, dynamic> event) {
    return [
      childId,
      event['type'] ?? '',
      event['title'] ?? '',
      event['time'] ?? '',
      event['zone_name'] ?? '',
    ].join('|');
  }

  Future<Set<String>> _loadSeenSignatures() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenEventsKey) ?? const []).toSet();
  }

  Future<void> _saveSeenSignatures(List<String> signatures) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = signatures.length > _maxStoredSignatures
        ? signatures.sublist(signatures.length - _maxStoredSignatures)
        : signatures;
    await prefs.setStringList(_seenEventsKey, trimmed);
  }

  Future<void> _showNotification(_PendingNotification notification) async {
    final bodyParts = <String>[
      if ((notification.zoneName?.isNotEmpty ?? false))
        'Zone: ${notification.zoneName}',
      if (notification.subtitle.isNotEmpty) notification.subtitle,
    ];

    await _plugin.show(
      notification.signature.hashCode & 0x7fffffff,
      '${notification.childName}: ${notification.title}',
      bodyParts.join(' · '),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

class _PendingNotification {
  const _PendingNotification({
    required this.childName,
    required this.title,
    required this.subtitle,
    required this.zoneName,
    required this.signature,
    required this.timestamp,
  });

  final String childName;
  final String title;
  final String subtitle;
  final String? zoneName;
  final String signature;
  final DateTime? timestamp;
}
