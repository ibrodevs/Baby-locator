import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';
import 'chat_visibility_service.dart';
import 'notification_dedupe_store.dart';

/// Polls the backend for unread messages and pending tasks for the child,
/// and shows local notifications. Works as a fallback when FCM pushes
/// are unavailable (e.g. Firebase service account not configured on server).
class ChildNotificationService {
  ChildNotificationService._();
  static final ChildNotificationService instance = ChildNotificationService._();

  static const _androidChannelId = 'kid_security_child_alerts';
  static const _androidChannelName = 'Family Security — Уведомления';
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Timer? _pollTimer;
  bool _initialized = false;
  bool _polling = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const initSettings = InitializationSettings(
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
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> ensurePermissions() async {
    await initialize();
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Start polling for the child session.
  Future<void> start() async {
    await initialize();
    await ensurePermissions();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _poll(),
    );
    unawaited(_poll());
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final notifications = await ApiClient.instance.childNotifications();
      if (notifications.isEmpty) return;

      final shownIds = await _loadShownIds();

      for (final item in notifications) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map['id'] as String? ?? '';
        if (id.isEmpty || shownIds.contains(id)) continue;

        if (ChatVisibilityService.instance.activeChildId != null) {
          shownIds.add(id);
          continue;
        }

        final title = map['title'] as String? ?? '';
        final body = map['body'] as String? ?? '';
        if (title.isEmpty) continue;

        await _showNotification(title: title, body: body);
        shownIds.add(id);
      }

      await _saveShownIds(shownIds);
    } catch (_) {
      // Network error — will retry next poll.
    } finally {
      _polling = false;
    }
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
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

  Future<Set<String>> _loadShownIds() async {
    return NotificationDedupeStore.loadChildShownIds();
  }

  Future<void> _saveShownIds(Set<String> ids) async {
    await NotificationDedupeStore.saveChildShownIds(ids);
  }
}
