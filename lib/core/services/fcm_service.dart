import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';
import 'background_command_service.dart';
import 'chat_visibility_service.dart';
import 'notification_dedupe_store.dart';

/// Global navigator key used by the app to push SOS screen from FCM handler.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

const _activityAlertsChannelId = 'kid_security_activity_alerts';
const _activityAlertsChannelName = 'Kid Security Alerts';
const _childAlertsChannelId = 'kid_security_child_alerts';
const _childAlertsChannelName = 'Kid Security — Уведомления';
const _sosAlertsChannelId = 'kid_security_sos';
const _sosAlertsChannelName = 'SOS Alerts';

const _activityAlertsChannel = AndroidNotificationChannel(
  _activityAlertsChannelId,
  _activityAlertsChannelName,
  description: 'Notifications about chat messages and activity alerts.',
  importance: Importance.high,
);

const _childAlertsChannel = AndroidNotificationChannel(
  _childAlertsChannelId,
  _childAlertsChannelName,
  description: 'Notifications shown on the child device.',
  importance: Importance.high,
);

const _sosAlertsChannel = AndroidNotificationChannel(
  _sosAlertsChannelId,
  _sosAlertsChannelName,
  description: 'Critical SOS alerts that require immediate attention.',
  importance: Importance.max,
);

/// Top-level handler — runs even when the app is killed.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();

  final data = message.data;
  final commandType = data['command_type'] ?? '';
  final notificationType = data['notification_type'] ?? '';

  // Handle child device commands — always wake the background service
  // which runs the foreground service (with microphone type) and reliably
  // polls the API for pending commands.
  if (commandType == 'loud' ||
      commandType == 'loud_stop' ||
      commandType == 'around_start' ||
      commandType == 'around_stop' ||
      commandType == 'sync_blocked_apps' ||
      commandType == 'webrtc_monitor_start' ||
      commandType == 'webrtc_monitor_stop') {
    await wakeChildBackgroundService(
      commandType: commandType,
      payload: Map<String, dynamic>.from(data),
    );
  }

  // Handle parent notifications in background — show local notification
  if (notificationType.isNotEmpty) {
    await _recordNotificationAsShown(data);
    if (message.notification == null) {
      await _showBackgroundNotification(message);
    }
  }
}

Future<void> _showBackgroundNotification(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(initSettings);
  await _ensureAndroidNotificationChannels(plugin);

  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] ?? 'Kid Security';
  final body = notification?.body ?? message.data['body'] ?? '';
  final notificationType = message.data['notification_type'] ?? '';

  var channel = _activityAlertsChannel;
  Importance importance = Importance.high;

  if (notificationType == 'sos') {
    channel = _sosAlertsChannel;
    importance = Importance.max;
  }

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: importance,
        priority: Priority.max,
        fullScreenIntent: notificationType == 'sos',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

/// Manages FCM initialization, token registration, and foreground message
/// handling.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  bool _initialized = false;
  bool _localNotificationsReady = false;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Callback invoked when an SOS push arrives in foreground.
  /// Set by app.dart to show the full-screen SOS overlay.
  void Function(String childName, String? message)? onSosReceived;

  /// Call once after Firebase.initializeApp().
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;
    await _ensureLocalNotificationsInitialized();

    // Request permission (iOS).
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages — handle commands directly.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      await _recordNotificationAsShown(initialMessage.data);
    }
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsReady) return;
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotificationsPlugin.initialize(initSettings);
    await _ensureAndroidNotificationChannels(_localNotificationsPlugin);
    _localNotificationsReady = true;
  }

  /// Registers the current FCM token with the backend.
  /// Call after login / on app start when authenticated.
  Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiClient.instance.registerFcmToken(token);
      }
    } catch (_) {
      // Token registration is best-effort.
    }

    // Listen for token refreshes.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await ApiClient.instance.registerFcmToken(newToken);
      } catch (_) {}
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final commandType = data['command_type'] ?? '';
    final notificationType = data['notification_type'] ?? '';

    // Handle child device commands — ensure the foreground background
    // service is running. It will pick up the command on its next poll
    // (and immediately via `pollNow` triggered inside wakeChildBackgroundService).
    if (commandType == 'loud' ||
        commandType == 'loud_stop' ||
        commandType == 'around_start' ||
        commandType == 'around_stop' ||
        commandType == 'sync_blocked_apps' ||
        commandType == 'webrtc_monitor_start' ||
        commandType == 'webrtc_monitor_stop') {
      unawaited(
        wakeChildBackgroundService(
          commandType: commandType,
          payload: Map<String, dynamic>.from(data),
        ),
      );
    }

    // Handle parent notifications in foreground
    if (notificationType.isNotEmpty) {
      unawaited(_recordNotificationAsShown(data));
      _handleNotification(message);
    }
  }

  void _handleNotification(RemoteMessage message) {
    final data = message.data;
    final notificationType = data['notification_type'] ?? '';
    final notification = message.notification;
    final title = notification?.title ?? data['title'] ?? '';
    final body = notification?.body ?? data['body'] ?? '';
    final childName = data['child_name'] ?? '';
    final childId = int.tryParse('${data['child_id'] ?? ''}');

    if (notificationType == 'sos') {
      // Show full-screen SOS alert
      onSosReceived?.call(
        childName.isNotEmpty ? childName : 'Child',
        body.isNotEmpty ? body : null,
      );
    } else {
      if ((notificationType == 'chat_message' ||
              notificationType == 'task_assigned') &&
          childId != null &&
          ChatVisibilityService.instance.isChatOpenFor(childId)) {
        return;
      }
      // Show local notification for chat_message, task_assigned, etc.
      _showLocalNotification(title: title, body: body);
    }
  }

  void _handleNotificationOpened(RemoteMessage message) {
    unawaited(_recordNotificationAsShown(message.data));
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    await _ensureLocalNotificationsInitialized();
    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _activityAlertsChannelId,
          _activityAlertsChannelName,
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
}

Future<void> _ensureAndroidNotificationChannels(
  FlutterLocalNotificationsPlugin plugin,
) async {
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin == null) return;

  await androidPlugin.createNotificationChannel(_activityAlertsChannel);
  await androidPlugin.createNotificationChannel(_childAlertsChannel);
  await androidPlugin.createNotificationChannel(_sosAlertsChannel);
}

Future<void> _recordNotificationAsShown(Map<String, dynamic> data) async {
  final alertId = int.tryParse('${data['alert_id'] ?? ''}');
  if (alertId != null) {
    await NotificationDedupeStore.recordParentAlert(alertId);
  }

  final messageId = int.tryParse('${data['message_id'] ?? ''}');
  if (messageId != null) {
    await NotificationDedupeStore.recordChildMessage(messageId);
  }

  final taskId = int.tryParse('${data['task_id'] ?? ''}');
  if (taskId != null) {
    await NotificationDedupeStore.recordChildTask(taskId);
  }
}
