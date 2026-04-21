# ПРОМТ ДЛЯ ИИ: Приложение мониторинга звука (родитель-ребёнок)

---

## КОНТЕКСТ ПРОЕКТА

Ты опытный Flutter и Django разработчик. Тебе нужно реализовать функцию **"Слушать вокруг"** в уже готовом приложении с двумя ролями: **родитель** и **ребёнок**.

**Цель**: Когда родитель нажимает кнопку "Слушать вокруг", он в реальном времени слышит то, что происходит вокруг телефона ребёнка. Это должно работать:
- Когда приложение свёрнуто (background)
- Когда экран телефона ребёнка выключен (locked screen)
- В реальном времени с минимальной задержкой

**Стек**: Flutter (мобильный клиент) + Django REST + Django Channels (WebSocket) + WebRTC

---

## АРХИТЕКТУРА РЕШЕНИЯ

```
Телефон ребёнка                Django сервер              Телефон родителя
      │                              │                            │
      │──── WebSocket (signaling) ───│──── WebSocket (signaling)──│
      │                              │                            │
      │◄──────────── WebRTC P2P аудио-поток ──────────────────────│
      │                              │                            │
      │◄─── FCM/APNs push ──────────│◄── REST запрос ────────────│
```

**Принцип**:
1. Родитель нажимает кнопку → Django посылает FCM/APNs push ребёнку
2. Push будит фоновый сервис на телефоне ребёнка
3. Оба телефона подключаются к Django Channels (WebSocket) для обмена SDP/ICE
4. Устанавливается прямой P2P WebRTC канал
5. Аудио идёт напрямую с телефона ребёнка на телефон родителя

---

## ЧАСТЬ 1: DJANGO BACKEND

### 1.1 Зависимости (requirements.txt)

```
channels==4.0.0
channels-redis==4.1.0
daphne==4.0.0
firebase-admin==6.2.0
djangorestframework==3.14.0
```

### 1.2 settings.py

```python
INSTALLED_APPS = [
    ...
    'channels',
    'daphne',
]

ASGI_APPLICATION = 'yourproject.asgi.application'

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            'hosts': [('127.0.0.1', 6379)],
        },
    },
}

# Firebase Admin SDK для FCM
FIREBASE_CREDENTIALS_PATH = '/path/to/firebase-credentials.json'
```

### 1.3 asgi.py

```python
import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from . import routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'yourproject.settings')

application = ProtocolTypeRouter({
    'http': get_asgi_application(),
    'websocket': AuthMiddlewareStack(
        URLRouter(routing.websocket_urlpatterns)
    ),
})
```

### 1.4 routing.py

```python
from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/monitor/(?P<family_id>\w+)/$', consumers.MonitorConsumer.as_asgi()),
]
```

### 1.5 consumers.py (ГЛАВНЫЙ ФАЙЛ)

```python
import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async

logger = logging.getLogger(__name__)

class MonitorConsumer(AsyncWebsocketConsumer):
    """
    Signaling сервер для WebRTC.
    Передаёт SDP offer/answer и ICE candidates между ребёнком и родителем.
    """

    async def connect(self):
        self.family_id = self.scope['url_route']['kwargs']['family_id']
        self.role = self.scope['query_string'].decode()  # role=child или role=parent
        self.room_group = f'monitor_{self.family_id}'

        await self.channel_layer.group_add(self.room_group, self.channel_name)
        await self.accept()
        logger.info(f'[{self.role}] подключился к комнате {self.family_id}')

        # Сообщаем всем в комнате что новый участник подключился
        await self.channel_layer.group_send(self.room_group, {
            'type': 'peer_joined',
            'role': self.role,
            'sender': self.channel_name,
        })

    async def disconnect(self, close_code):
        await self.channel_layer.group_send(self.room_group, {
            'type': 'peer_left',
            'role': self.role,
            'sender': self.channel_name,
        })
        await self.channel_layer.group_discard(self.room_group, self.channel_name)

    async def receive(self, text_data):
        """Получаем SDP или ICE от одного участника и пересылаем другому."""
        try:
            data = json.loads(text_data)
            data['sender'] = self.channel_name
            await self.channel_layer.group_send(self.room_group, {
                'type': 'signal_message',
                'data': data,
                'sender': self.channel_name,
            })
        except json.JSONDecodeError:
            logger.error('Невалидный JSON в signaling')

    async def signal_message(self, event):
        """Пересылаем сигнал всем кроме отправителя."""
        if event['sender'] != self.channel_name:
            await self.send(text_data=json.dumps(event['data']))

    async def peer_joined(self, event):
        if event['sender'] != self.channel_name:
            await self.send(text_data=json.dumps({
                'type': 'peer_joined',
                'role': event['role'],
            }))

    async def peer_left(self, event):
        if event['sender'] != self.channel_name:
            await self.send(text_data=json.dumps({'type': 'peer_left'}))
```

### 1.6 views.py (REST endpoint для активации)

```python
import firebase_admin
from firebase_admin import credentials, messaging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import os

# Инициализация Firebase (делай один раз при старте)
cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
firebase_admin.initialize_app(cred)

class ActivateMonitoringView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        """
        Родитель вызывает этот endpoint.
        Он посылает push-уведомление на телефон ребёнка.
        """
        child_fcm_token = request.data.get('child_fcm_token')
        family_id = request.data.get('family_id')

        if not child_fcm_token:
            return Response({'error': 'fcm_token required'}, status=400)

        # Посылаем data-push (не notification!) чтобы он работал в фоне
        message = messaging.Message(
            data={
                'type': 'START_MONITORING',
                'family_id': family_id,
            },
            android=messaging.AndroidConfig(
                priority='high',  # КРИТИЧНО: иначе push придёт с задержкой
                ttl=60,
            ),
            apns=messaging.APNSConfig(
                headers={'apns-priority': '10'},  # iOS высокий приоритет
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        content_available=True,  # iOS background push
                        sound=None,
                    )
                ),
            ),
            token=child_fcm_token,
        )

        response = messaging.send(message)
        return Response({'message_id': response})


class SaveFCMTokenView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        """Сохраняем FCM токен пользователя при логине."""
        token = request.data.get('fcm_token')
        # Сохрани в модель User или Profile
        request.user.profile.fcm_token = token
        request.user.profile.save()
        return Response({'status': 'ok'})
```

### 1.7 urls.py

```python
urlpatterns = [
    path('api/monitor/activate/', ActivateMonitoringView.as_view()),
    path('api/fcm-token/', SaveFCMTokenView.as_view()),
]
```

---

## ЧАСТЬ 2: FLUTTER — ОБЩИЕ ЗАВИСИМОСТИ

### 2.1 pubspec.yaml

```yaml
dependencies:
  flutter_webrtc: ^0.9.47          # WebRTC
  web_socket_channel: ^2.4.0       # WebSocket для signaling
  firebase_core: ^2.24.0           # Firebase
  firebase_messaging: ^14.7.10     # FCM push уведомления
  flutter_foreground_task: ^6.1.3  # Android Foreground Service
  permission_handler: ^11.1.0      # Запрос разрешений
  dio: ^5.4.0                      # HTTP клиент
```

### 2.2 Модели данных

```dart
// lib/models/webrtc_signal.dart
class WebRTCSignal {
  final String type; // 'offer', 'answer', 'ice_candidate', 'peer_joined', 'peer_left'
  final String? sdp;
  final Map<String, dynamic>? candidate;

  WebRTCSignal({required this.type, this.sdp, this.candidate});

  factory WebRTCSignal.fromJson(Map<String, dynamic> json) => WebRTCSignal(
    type: json['type'],
    sdp: json['sdp'],
    candidate: json['candidate'],
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    if (sdp != null) 'sdp': sdp,
    if (candidate != null) 'candidate': candidate,
  };
}
```

---

## ЧАСТЬ 3: FLUTTER — СТОРОНА РЕБЁНКА

### 3.1 Android — AndroidManifest.xml

Добавь в `android/app/src/main/AndroidManifest.xml` перед `<application>`:

```xml
<!-- Разрешения -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Внутри <application> -->
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="microphone"
    android:exported="false"/>
```

### 3.2 iOS — Info.plist

Добавь в `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Приложение использует микрофон для мониторинга безопасности ребёнка</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3.3 iOS — AppDelegate.swift

```swift
import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Настраиваем аудио сессию для фоновой работы
        configureAudioSession()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // playAndRecord + allowBluetooth + defaultToSpeaker
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .defaultToSpeaker, .mixWithOthers]
            )
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
}
```

### 3.4 Сервис ребёнка — child_audio_service.dart

```dart
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

class ChildAudioService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  WebSocketChannel? _signalingChannel;
  bool _isActive = false;

  // TURN сервер — обязателен для работы через разные сети
  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': 'turn:YOUR_TURN_SERVER:3478',
        'username': 'YOUR_USERNAME',
        'credential': 'YOUR_PASSWORD',
      },
    ],
  };

  /// Вызывается при получении FCM push от родителя
  Future<void> startMonitoring(String familyId) async {
    if (_isActive) return;
    _isActive = true;

    // 1. Запрашиваем разрешение на микрофон
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return;

    // 2. Запускаем Foreground Service (Android) — обязательно!
    await _startForegroundService();

    // 3. Захватываем аудио с микрофона
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': false,   // Не убираем эхо — хотим слышать всё
        'noiseSuppression': false,   // Не подавляем шум
        'autoGainControl': false,    // Не меняем громкость автоматически
        'channelCount': 1,           // Моно — экономит трафик
        'sampleRate': 16000,         // 16kHz достаточно для мониторинга
      },
      'video': false,
    });

    // 4. Создаём WebRTC соединение
    _peerConnection = await createPeerConnection(_iceServers);

    // 5. Добавляем локальный аудио-трек
    _localStream!.getAudioTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // 6. Подключаемся к signaling серверу
    _connectSignaling(familyId);

    // 7. Обрабатываем ICE candidates
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _sendSignal({
          'type': 'ice_candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };

    _peerConnection!.onConnectionState = (state) {
      print('[Child] WebRTC state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        stopMonitoring();
      }
    };
  }

  void _connectSignaling(String familyId) {
    _signalingChannel = WebSocketChannel.connect(
      Uri.parse('wss://YOUR_SERVER/ws/monitor/$familyId/?role=child'),
    );

    _signalingChannel!.stream.listen(
      (message) => _handleSignal(json.decode(message)),
      onError: (e) => print('[Child] WebSocket error: $e'),
      onDone: () => print('[Child] WebSocket closed'),
    );
  }

  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final type = data['type'];

    switch (type) {
      case 'peer_joined':
        // Родитель подключился — ребёнок создаёт offer
        if (data['role'] == 'parent') {
          await _createAndSendOffer();
        }
        break;

      case 'answer':
        // Родитель принял offer
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], 'answer'),
        );
        break;

      case 'ice_candidate':
        // Добавляем ICE candidate от родителя
        final c = data['candidate'];
        await _peerConnection!.addCandidate(RTCIceCandidate(
          c['candidate'],
          c['sdpMid'],
          c['sdpMLineIndex'],
        ));
        break;
    }
  }

  Future<void> _createAndSendOffer() async {
    final offer = await _peerConnection!.createOffer({
      'offerToReceiveAudio': false, // Ребёнок только отправляет, не получает
      'offerToReceiveVideo': false,
    });
    await _peerConnection!.setLocalDescription(offer);
    _sendSignal({'type': 'offer', 'sdp': offer.sdp});
  }

  void _sendSignal(Map<String, dynamic> data) {
    _signalingChannel?.sink.add(json.encode(data));
  }

  Future<void> _startForegroundService() async {
    // Инициализация (делай один раз в main.dart)
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'monitoring_channel',
        channelName: 'Мониторинг',
        channelDescription: 'Активен режим мониторинга',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,   // КРИТИЧНО: держит CPU активным
        allowWifiLock: true,   // КРИТИЧНО: держит Wi-Fi активным
      ),
    );

    await FlutterForegroundTask.startService(
      notificationTitle: 'Режим мониторинга активен',
      notificationText: 'Родитель слушает окружение',
    );
  }

  Future<void> stopMonitoring() async {
    _isActive = false;
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream?.dispose();
    _localStream = null;
    _signalingChannel?.sink.close();
    await FlutterForegroundTask.stopService();
  }
}
```

### 3.5 Обработчик FCM push на стороне ребёнка

```dart
// lib/services/fcm_handler.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMHandler {
  static final _childAudioService = ChildAudioService();

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // Запрашиваем разрешение на уведомления (iOS)
    await messaging.requestPermission(
      alert: true,
      badge: false,
      sound: false,
    );

    // Сохраняем FCM токен на сервере
    final token = await messaging.getToken();
    if (token != null) await _saveFCMToken(token);

    // Слушаем обновление токена
    messaging.onTokenRefresh.listen(_saveFCMToken);

    // Обработка push когда приложение в фоне/убито
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Обработка push когда приложение активно
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  static Future<void> _saveFCMToken(String token) async {
    // Отправляем токен на Django сервер
    await ApiService.post('/api/fcm-token/', {'fcm_token': token});
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    _processMessage(message);
  }

  static Future<void> _processMessage(RemoteMessage message) async {
    final type = message.data['type'];
    final familyId = message.data['family_id'];

    if (type == 'START_MONITORING' && familyId != null) {
      // Запускаем мониторинг
      await _childAudioService.startMonitoring(familyId);
    } else if (type == 'STOP_MONITORING') {
      await _childAudioService.stopMonitoring();
    }
  }
}

// ВАЖНО: Эта функция должна быть top-level (не метод класса)
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Firebase должен быть инициализирован
  await Firebase.initializeApp();
  final type = message.data['type'];
  final familyId = message.data['family_id'];

  if (type == 'START_MONITORING' && familyId != null) {
    final service = ChildAudioService();
    await service.startMonitoring(familyId);
  }
}
```

---

## ЧАСТЬ 4: FLUTTER — СТОРОНА РОДИТЕЛЯ

### 4.1 Сервис родителя — parent_listener_service.dart

```dart
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ParentListenerService {
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer? _remoteRenderer;
  WebSocketChannel? _signalingChannel;
  bool _isListening = false;

  // Callback для UI — вызывается когда аудио началось
  Function()? onAudioStarted;
  Function()? onAudioStopped;
  Function(String)? onError;

  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': 'turn:YOUR_TURN_SERVER:3478',
        'username': 'YOUR_USERNAME',
        'credential': 'YOUR_PASSWORD',
      },
    ],
  };

  Future<void> startListening({
    required String familyId,
    required String childFcmToken,
  }) async {
    if (_isListening) return;
    _isListening = true;

    // 1. Создаём WebRTC соединение
    _peerConnection = await createPeerConnection(_iceServers);

    // 2. Обрабатываем входящий аудио-трек от ребёнка
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'audio') {
        // Аудио трек получен — WebRTC автоматически воспроизведёт через динамик
        print('[Parent] Получен аудио-трек от ребёнка');
        onAudioStarted?.call();
      }
    };

    // 3. Обрабатываем ICE candidates
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _sendSignal({
          'type': 'ice_candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };

    _peerConnection!.onConnectionState = (state) {
      print('[Parent] WebRTC state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        onAudioStopped?.call();
        stopListening();
      }
    };

    // 4. Подключаемся к signaling серверу
    _connectSignaling(familyId);

    // 5. Посылаем FCM push ребёнку через наш Django сервер
    try {
      await ApiService.post('/api/monitor/activate/', {
        'child_fcm_token': childFcmToken,
        'family_id': familyId,
      });
    } catch (e) {
      onError?.call('Не удалось отправить сигнал ребёнку');
      await stopListening();
    }
  }

  void _connectSignaling(String familyId) {
    _signalingChannel = WebSocketChannel.connect(
      Uri.parse('wss://YOUR_SERVER/ws/monitor/$familyId/?role=parent'),
    );

    _signalingChannel!.stream.listen(
      (message) => _handleSignal(json.decode(message)),
      onError: (e) {
        onError?.call('Ошибка соединения');
        stopListening();
      },
    );
  }

  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final type = data['type'];

    switch (type) {
      case 'offer':
        // Получили offer от ребёнка — создаём answer
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], 'offer'),
        );
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        _sendSignal({'type': 'answer', 'sdp': answer.sdp});
        break;

      case 'ice_candidate':
        final c = data['candidate'];
        await _peerConnection!.addCandidate(RTCIceCandidate(
          c['candidate'],
          c['sdpMid'],
          c['sdpMLineIndex'],
        ));
        break;

      case 'peer_left':
        onAudioStopped?.call();
        await stopListening();
        break;
    }
  }

  void _sendSignal(Map<String, dynamic> data) {
    _signalingChannel?.sink.add(json.encode(data));
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _peerConnection?.close();
    _peerConnection = null;
    _signalingChannel?.sink.close();

    // Посылаем push ребёнку чтобы он остановил стриминг
    await ApiService.post('/api/monitor/deactivate/', {});
  }

  bool get isListening => _isListening;
}
```

### 4.2 UI виджет для родителя

```dart
// lib/screens/parent/monitor_screen.dart
import 'package:flutter/material.dart';

class MonitorButton extends StatefulWidget {
  final String familyId;
  final String childFcmToken;

  const MonitorButton({
    required this.familyId,
    required this.childFcmToken,
    super.key,
  });

  @override
  State<MonitorButton> createState() => _MonitorButtonState();
}

class _MonitorButtonState extends State<MonitorButton> {
  final _service = ParentListenerService();
  bool _isListening = false;
  String _status = 'Нажмите чтобы слушать';

  @override
  void initState() {
    super.initState();
    _service.onAudioStarted = () => setState(() {
      _status = 'Слушаю вокруг ребёнка...';
    });
    _service.onAudioStopped = () => setState(() {
      _isListening = false;
      _status = 'Нажмите чтобы слушать';
    });
    _service.onError = (msg) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {
        _isListening = false;
        _status = 'Нажмите чтобы слушать';
      });
    };
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _service.stopListening();
      setState(() {
        _isListening = false;
        _status = 'Нажмите чтобы слушать';
      });
    } else {
      setState(() {
        _isListening = true;
        _status = 'Подключаюсь...';
      });
      await _service.startListening(
        familyId: widget.familyId,
        childFcmToken: widget.childFcmToken,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? Colors.red : Colors.blue,
              boxShadow: _isListening
                  ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)]
                  : [],
            ),
            child: Icon(
              _isListening ? Icons.hearing : Icons.hearing_disabled,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(_status, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  @override
  void dispose() {
    _service.stopListening();
    super.dispose();
  }
}
```

---

## ЧАСТЬ 5: ГЛАВНАЯ ТОЧКА ВХОДА

### 5.1 main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'services/fcm_handler.dart';

// Обязательно top-level для background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FCMHandler.processMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FCMHandler.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}
```

---

## ЧАСТЬ 6: ИНФРАСТРУКТУРА

### 6.1 Настройка TURN сервера (coturn) на сервере

```bash
# Установка
sudo apt install coturn

# /etc/turnserver.conf
listening-port=3478
tls-listening-port=5349
fingerprint
lt-cred-mech
user=YOUR_USERNAME:YOUR_PASSWORD
realm=yourdomain.com
log-file=/var/log/coturn/turnserver.log
```

### 6.2 Nginx конфигурация для WebSocket

```nginx
location /ws/ {
    proxy_pass http://127.0.0.1:8000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_read_timeout 86400;  # 24 часа — для длинных сессий
}
```

---

## ЧЕКЛИСТ ПЕРЕД ТЕСТИРОВАНИЕМ

- [ ] Django Channels + Redis работают
- [ ] FCM ключи настроены в Firebase Console
- [ ] `google-services.json` добавлен в `android/app/`
- [ ] `GoogleService-Info.plist` добавлен в `ios/Runner/`
- [ ] TURN сервер доступен
- [ ] `AndroidManifest.xml` содержит все разрешения и `foregroundServiceType="microphone"`
- [ ] iOS `Info.plist` содержит `UIBackgroundModes` с `audio` и `voip`
- [ ] Тест: приложение ребёнка работает с выключенным экраном
- [ ] Тест: соединение через мобильный интернет (не только Wi-Fi) — нужен TURN

---

## ВАЖНЫЕ НЮАНСЫ

**Android**: `FOREGROUND_SERVICE_MICROPHONE` требует Android 14+. Для более старых версий достаточно `FOREGROUND_SERVICE`. Также на Android 13+ нужно разрешение `POST_NOTIFICATIONS`.

**iOS**: Без `voip` в `UIBackgroundModes` приложение будет убито системой через ~30 секунд в фоне. С `voip` — работает неограниченно.

**WebRTC vs простой стриминг**: WebRTC выбран намеренно — он адаптирует битрейт под качество сети, автоматически восстанавливает соединение при потере пакетов, и работает P2P не нагружая сервер.

**Безопасность**: Обязательно добавь JWT аутентификацию в WebSocket соединение через `AuthMiddlewareStack` и проверяй что родитель действительно принадлежит к той же семье что и ребёнок.
