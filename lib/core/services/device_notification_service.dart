import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'chat_visibility_service.dart';
import 'fcm_service.dart';
import 'notification_dedupe_store.dart';

InterruptionLevel _deviceIosInterruptionLevelForNotificationType(
  String notificationType,
) {
  switch (notificationType) {
    case 'sos':
    case 'battery_low':
    case 'safe_zone_exit':
    case 'location_update':
      return InterruptionLevel.timeSensitive;
    case 'chat_message':
    case 'task_assigned':
      return InterruptionLevel.active;
    default:
      return InterruptionLevel.active;
  }
}

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
  static const _androidChannelName = 'Family Security Alerts';
  static const _androidChannelDescription =
      'Notifications about children activity, battery, and safe zones.';
  static const _sosChannelId = 'kid_security_sos';
  static const _sosChannelName = 'SOS Alerts';
  static const _sosChannelDescription =
      'Critical SOS alerts that require immediate attention.';
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationSettingsModel _settings = NotificationSettingsModel.defaults;
  Timer? _pollingTimer;
  bool _initialized = false;
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

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        FcmService.instance.handleNotificationPayloadString(response.payload);
      },
    );
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: _androidChannelDescription,
          importance: Importance.high,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _sosChannelId,
          _sosChannelName,
          description: _sosChannelDescription,
          importance: Importance.max,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
    }
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
      _cancelTimer();
      // Poll more frequently so chat/task alerts still feel fast
      // even when FCM delivery is unavailable.
      _pollingTimer = Timer.periodic(
        const Duration(seconds: 8),
        (_) => _poll(),
      );
      // Run immediately on start.
      unawaited(_poll());
    }
  }

  Future<void> refreshNow() async {
    if (_activeParentId == null) return;
    await initialize();
    _settings = await NotificationSettingsStore.load();
    if (!_settings.pushEnabled) return;
    await _poll();
  }

  void stop() {
    _activeParentId = null;
    _cancelTimer();
  }

  void _cancelTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _poll() async {
    if (_pollInFlight || _activeParentId == null) return;
    _pollInFlight = true;
    try {
      final alerts =
          (await ApiClient.instance.getAlerts()).cast<Map<String, dynamic>>();
      if (alerts.isEmpty) return;

      final shownIds = await _loadShownIds();
      final markReadIds = <int>[];

      for (final alert in alerts) {
        final id = alert['id'] as int;
        final alertType = alert['alert_type'] as String? ?? '';
        final childName = alert['child_name'] as String? ?? '';
        final childId = alert['child'] as int?;
        final title = alert['title'] as String? ?? '';
        final message = alert['message'] as String? ?? '';

        // Always mark server alerts as read so they don't pile up.
        markReadIds.add(id);

        // Skip if already shown locally.
        if (shownIds.contains(id.toString())) continue;

        if ((alertType == 'chat_message' || alertType == 'task_assigned') &&
            childId != null &&
            ChatVisibilityService.instance.isChatOpenFor(childId)) {
          continue;
        }

        // Check user settings.
        if (!_shouldShow(alertType)) continue;

        if (alertType == 'sos') {
          await _showSosNotification(
            id: id,
            title: title,
            body: message.isNotEmpty ? message : childName,
            childId: childId,
            childName: childName,
          );
        } else {
          await _showNotification(
            id: id,
            title: title,
            body: message.isNotEmpty ? message : childName,
            alertType: alertType,
          );
        }
      }

      // Persist shown IDs.
      final allShown = {...shownIds, ...markReadIds.map((id) => id.toString())};
      await _saveShownIds(allShown);

      // Mark read on server.
      for (final id in markReadIds) {
        try {
          await ApiClient.instance.markAlertRead(id);
        } catch (_) {}
      }
    } catch (_) {
      // Network error – will retry on next poll.
    } finally {
      _pollInFlight = false;
    }
  }

  bool _shouldShow(String alertType) {
    if (alertType == 'sos') return true;
    if (alertType == 'chat_message' || alertType == 'task_assigned') {
      return true;
    }
    if (alertType == 'location_update') return _settings.locationAlerts;
    if (alertType == 'battery_low') return _settings.batteryAlerts;
    if (alertType == 'safe_zone_exit') return _settings.safeZoneAlerts;
    return _settings.locationAlerts;
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String alertType = '',
  }) async {
    await _plugin.show(
      id & 0x7fffffff,
      title,
      body,
      NotificationDetails(
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
          interruptionLevel:
              _deviceIosInterruptionLevelForNotificationType(alertType),
        ),
      ),
    );
  }

  Future<void> _showSosNotification({
    required int id,
    required String title,
    required String body,
    required int? childId,
    required String childName,
  }) async {
    final payload = <String, dynamic>{
      'notification_type': 'sos',
      'title': title,
      'body': body,
      'alert_id': id,
      if (childId != null) 'child_id': childId,
      'child_name': childName.isNotEmpty ? childName : 'Child',
    };
    await _plugin.show(
      id & 0x7fffffff,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _sosChannelId,
          _sosChannelName,
          channelDescription: _sosChannelDescription,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
          additionalFlags: Int32List.fromList(const [4]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: jsonEncode(payload),
    );
    await FcmService.instance.presentSosAlert(payload);
  }

  Future<Set<String>> _loadShownIds() async {
    return NotificationDedupeStore.loadParentAlertShownIds();
  }

  Future<void> _saveShownIds(Set<String> ids) async {
    await NotificationDedupeStore.saveParentAlertShownIds(ids);
  }
}
