# Функция «Слушать / Звук вокруг» (WebRTC) — диагноз

> Важно: эта функция **не относится** к 4 причинам отказа Google Play. По решению
> оставляем её на **WebRTC** (код не меняли). Этот файл — только диагностика и что
> нужно на сервере, чтобы WebRTC стабильно работал.

## Что показали логи gunicorn

При нажатии «Слушать»:
```
POST /api/monitor/activate/            200
Firebase service account key not found ...    ← FCM НЕ отправляется
Firebase not initialized, skipping FCM push
GET  /api/monitor/signal/poll/ ... (много раз)
POST /api/monitor/signal/send/         201
POST /api/monitor/deactivate/          200   ← сессия закрылась через ~4 сек → ошибка
```

## Две причины, почему WebRTC падает

1. **Нет TURN-сервера.** `WEBRTC_TURN_URLS` пуст → клиенту отдаётся только STUN.
   На мобильном интернете / симметричном NAT WebRTC не устанавливает соединение и
   сессия закрывается через несколько секунд. Комментарий в самом коде
   (`IceServersView`) прямо это описывает.

2. **Firebase сломан.** На сервере нет файла `firebase-service-account.json` →
   **все push-уведомления пропускаются**. Ребёнка нельзя разбудить, когда его
   приложение закрыто/экран заблокирован. Это ломает не только прослушку, но и
   **SOS** и уведомления зон.

## Что нужно сделать на сервере

### 1. Восстановить Firebase (обязательно — для SOS, зон и пробуждения закрытого приложения)
1. Firebase Console → Project settings → **Service accounts** → **Generate new
   private key** → скачать JSON.
2. Положить на сервер по пути из `config/settings.py`
   (`BASE_DIR/firebase-service-account.json`) или задать `FIREBASE_SERVICE_ACCOUNT_KEY`:
   ```bash
   scp firebase-service-account.json root@SERVER:/var/www/Baby-locator-backend/firebase-service-account.json
   chmod 600 /var/www/Baby-locator-backend/firebase-service-account.json
   pip show firebase-admin || pip install firebase-admin
   sudo systemctl restart gunicorn
   ```
   После рестарта строки `Firebase not initialized` должны исчезнуть.

### 2. Поднять TURN-сервер (coturn) для WebRTC
Пример (coturn, режим use-auth-secret):
```bash
sudo apt install coturn
# /etc/turnserver.conf:
#   use-auth-secret
#   static-auth-secret=<ДЛИННЫЙ_СЕКРЕТ>
#   realm=<ваш-домен>
#   listening-port=3478
#   tls-listening-port=5349
```
В `.env` бэкенда:
```bash
WEBRTC_TURN_URLS=turn:<ваш-домен>:3478,turns:<ваш-домен>:5349
WEBRTC_TURN_SECRET=<ТОТ_ЖЕ_ДЛИННЫЙ_СЕКРЕТ>
```
Перезапустить gunicorn. Теперь `/api/webrtc/ice-servers/` отдаёт TURN, и прослушка
работает на мобильных сетях.

> Ограничение WebRTC: захват микрофона в фоне при заблокированном экране на Android
> в вашем коде помечен как ненадёжный. Если понадобится 100% работа при полностью
> свёрнутом/закрытом приложении ребёнка — есть альтернативный HTTP-relay пайплайн
> (`ParentAroundAudioService` + `tracking/live_audio.py`), но это уже отдельная
> задача, не связанная с Google Play.
