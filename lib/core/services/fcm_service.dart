import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
const _listenWakeChannelId = 'kid_security_listen_wake';
const _listenWakeChannelName = 'Kid Security — Listen';
const _pendingWebrtcSessionKey = 'pending_webrtc_session_token';
const _pendingWebrtcSessionAtKey = 'pending_webrtc_session_at_ms';

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

/// Silent, hidden channel used solely to fire a full-screen-intent that wakes
/// the main activity over the lockscreen so `flutter_webrtc` can capture
/// audio in the main Flutter isolate. Category=call lets Android grant
/// USE_FULL_SCREEN_INTENT without the user-managed permission on Android 14+.
const _listenWakeChannel = AndroidNotificationChannel(
  _listenWakeChannelId,
  _listenWakeChannelName,
  description: 'Wakes the device when a parent starts listening.',
  importance: Importance.max,
  playSound: false,
  enableVibration: false,
  showBadge: false,
);
const _pendingSosPayloadKey = 'pending_sos_payload';

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
    if (commandType == 'webrtc_monitor_start') {
      final token = (data['session_token'] ?? '').toString();
      if (token.isNotEmpty) {
        await _persistPendingWebrtcSession(token);
        await _postListenWakeNotification(token);
      }
    } else if (commandType == 'webrtc_monitor_stop') {
      await _clearPendingWebrtcSession();
      await _cancelListenWakeNotification();
    }
    await wakeChildBackgroundService(
      commandType: commandType,
      payload: Map<String, dynamic>.from(data),
    );
  }

  // Handle parent notifications in background — show local notification
  if (notificationType.isNotEmpty) {
    if (notificationType == 'sos') {
      await _persistPendingSosPayload(data);
    }
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
        category: notificationType == 'sos'
            ? AndroidNotificationCategory.alarm
            : null,
        visibility:
            notificationType == 'sos' ? NotificationVisibility.public : null,
        ongoing: notificationType == 'sos',
        autoCancel: notificationType != 'sos',
        additionalFlags:
            notificationType == 'sos' ? Int32List.fromList(const [4]) : null,
        audioAttributesUsage: notificationType == 'sos'
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        fullScreenIntent: notificationType == 'sos',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel:
            notificationType == 'sos' ? InterruptionLevel.timeSensitive : null,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

/// Manages FCM initialization, token registration, and foreground message
/// handling.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  bool _initialized = false;
  bool _localNotificationsReady = false;
  Map<String, dynamic>? _pendingSosPayload;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Callback invoked when an SOS push arrives in foreground.
  /// Set by app.dart to show the full-screen SOS overlay.
  void Function(String childName, String? message)? _onSosReceived;

  set onSosReceived(
      void Function(String childName, String? message)? callback) {
    _onSosReceived = callback;
    _flushPendingSos();
  }

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

    await _requestAndroidFullScreenPermission();

    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages — handle commands directly.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    final launchDetails =
        await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _handleNotificationPayload(
        launchDetails?.notificationResponse?.payload,
      );
    }
    await restorePendingSosFromDisk();

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      await _recordNotificationAsShown(initialMessage.data);
      _handleNotification(initialMessage);
    }
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsReady) return;
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
    );
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
      _showSosOverlay(
        childName: childName.isNotEmpty ? childName : 'Child',
        message: body.isNotEmpty ? body : null,
        rawData: data,
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
    _handleNotification(message);
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

  void _handleLocalNotificationResponse(NotificationResponse response) {
    _handleNotificationPayload(response.payload);
  }

  void handleNotificationPayloadString(String? payload) {
    _handleNotificationPayload(payload);
  }

  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return;
      if ((decoded['notification_type'] ?? '') != 'sos') return;
      final body = '${decoded['body'] ?? ''}'.trim();
      _showSosOverlay(
        childName: '${decoded['child_name'] ?? 'Child'}',
        message: body.isNotEmpty ? body : null,
        rawData: decoded,
      );
      unawaited(_clearPendingSosPayload());
    } catch (_) {
      // Ignore malformed notification payloads.
    }
  }

  void _showSosOverlay({
    required String childName,
    required String? message,
    required Map<String, dynamic> rawData,
  }) {
    if (_onSosReceived != null) {
      _onSosReceived!.call(childName, message);
      return;
    }
    _pendingSosPayload = Map<String, dynamic>.from(rawData);
  }

  void _flushPendingSos() {
    final pending = _pendingSosPayload;
    if (pending == null || _onSosReceived == null) return;
    _pendingSosPayload = null;
    final body = '${pending['body'] ?? ''}'.trim();
    _onSosReceived!.call(
      '${pending['child_name'] ?? 'Child'}',
      body.isNotEmpty ? body : null,
    );
  }

  Future<void> restorePendingSosFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingSosPayloadKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      final body = '${decoded['body'] ?? ''}'.trim();
      _showSosOverlay(
        childName: '${decoded['child_name'] ?? 'Child'}',
        message: body.isNotEmpty ? body : null,
        rawData: decoded,
      );
    } catch (_) {
      // Ignore malformed persisted payloads.
    } finally {
      await _clearPendingSosPayload();
    }
  }

  Future<void> _requestAndroidFullScreenPermission() async {
    final androidPlugin =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestFullScreenIntentPermission();
  }
}

Future<void> _persistPendingSosPayload(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_pendingSosPayloadKey, jsonEncode(data));
}

Future<void> _clearPendingSosPayload() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_pendingSosPayloadKey);
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
  await androidPlugin.createNotificationChannel(_listenWakeChannel);
}

const _listenWakeNotificationId = 909191;

Future<void> _persistPendingWebrtcSession(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_pendingWebrtcSessionKey, token);
  await prefs.setInt(
    _pendingWebrtcSessionAtKey,
    DateTime.now().millisecondsSinceEpoch,
  );
}

Future<void> _clearPendingWebrtcSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_pendingWebrtcSessionKey);
  await prefs.remove(_pendingWebrtcSessionAtKey);
}

/// Posts a high-priority full-screen-intent notification that launches
/// MainActivity over the lockscreen. The activity has `showWhenLocked` and
/// `turnScreenOn` set, so once the main isolate boots it can read the
/// pending session token from SharedPreferences and start WebRTC capture.
Future<void> _postListenWakeNotification(String sessionToken) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(initSettings);
  await _ensureAndroidNotificationChannels(plugin);

  await plugin.show(
    _listenWakeNotificationId,
    'Kid Security',
    '',
    NotificationDetails(
      android: AndroidNotificationDetails(
        _listenWakeChannel.id,
        _listenWakeChannel.name,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        ongoing: false,
        autoCancel: true,
        playSound: false,
        enableVibration: false,
        silent: true,
        visibility: NotificationVisibility.secret,
      ),
    ),
    payload: jsonEncode({'listen_wake': true, 'session_token': sessionToken}),
  );
}

Future<void> _cancelListenWakeNotification() async {
  final plugin = FlutterLocalNotificationsPlugin();
  try {
    await plugin.cancel(_listenWakeNotificationId);
  } catch (_) {}
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
