# Анализ готовности приложения Family security

Дата анализа: 2026-04-24

## Краткий вывод

Проект уже находится на хорошем этапе и выглядит как **почти завершённый MVP / beta**, а не как сырой прототип. Основные пользовательские сценарии реализованы:

- регистрация родителя и ребёнка;
- инвайт-коды;
- карта и геолокация;
- безопасные зоны;
- чат;
- SOS;
- фоновая отправка локации и команд;
- статистика устройства и лимиты приложений;
- блокировка приложений на Android;
- backend API под эти сценарии.

При этом до состояния **"готово на 100%"** проект пока не дотягивает. По итогам ревью я бы оценил текущую готовность примерно в **80-85%**.

Главные причины:

- есть production-хвосты в конфигурации и деплое;
- web-часть не доведена до рабочего состояния;
- тестовое покрытие почти отсутствует;
- локализация завершена не полностью;
- документация устарела и не отражает фактическую архитектуру;
- есть несколько точечных UX/логических недоработок.

## Что уже выглядит завершённым

### 1. Архитектурный каркас

- Flutter-клиент структурирован по `features/`, `core/`, `services/`.
- Django backend содержит отдельные модули `accounts`, `tracking`, `chat`.
- API между клиентом и backend в целом согласован.
- Есть Riverpod-состояние, локаль, сессия, фоновые сервисы и push-логика.

### 2. Основной продуктовый функционал

- Родительский и детский режимы разделены.
- Есть onboarding / auth flow.
- Реализованы children CRUD, аватары, invite code flow.
- Есть safe zones, activity/history, alerts, stats summary.
- Есть remote device commands: loud signal, around audio, monitoring.
- Есть app usage sync, app limits и blocked apps.

### 3. Техническая проверка

- `flutter test` проходит успешно.
- `flutter analyze` не показывает blocking-ошибок компиляции.
- `backend/.venv/bin/python backend/manage.py check` проходит без ошибок.

## Что осталось, чтобы считать проект завершённым на 100%

### 1. Закрыть production-конфигурацию и релизные хвосты

Это самый важный блок.

- В Android всё ещё используется шаблонный `applicationId = "com.example.kid_security"` и оставлен TODO на релизную подпись в [android/app/build.gradle.kts](/Users/imac5/Desktop/baby_locator/android/app/build.gradle.kts:25).
- Базовый backend URL захардкожен в [lib/core/services/api_client.dart](/Users/imac5/Desktop/baby_locator/lib/core/services/api_client.dart:13), а invite-ссылки тоже завязаны на конкретный PythonAnywhere домен в клиенте и локализациях.
- `python manage.py check --deploy` выдаёт 6 предупреждений безопасности: `DEBUG=True`, слабый `SECRET_KEY`, нет `SECURE_SSL_REDIRECT`, `HSTS`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`.

Что нужно сделать:

- вынести все env/config значения из кода;
- подготовить release signing;
- настроить production Django settings;
- проверить реальные домены, HTTPS и redirect policy;
- убрать привязку к одному окружению из UI и ARB-строк.

### 2. Довести web-версию до рабочего состояния

Сейчас web нельзя считать завершённым.

- В [web/index.html](/Users/imac5/Desktop/baby_locator/web/index.html:34) и [web/index.html](/Users/imac5/Desktop/baby_locator/web/index.html:35) стоят плейсхолдеры для Apple MapKit и Google Maps.
- В [lib/features/map/apple_map_web.dart](/Users/imac5/Desktop/baby_locator/lib/features/map/apple_map_web.dart:45) используется `YOUR_APPLE_MAPKIT_JS_TOKEN`.
- Значит web maps заведомо не готовы к реальному использованию без ручной конфигурации.

Что нужно сделать:

- внедрить реальные web keys/tokens через env/build config;
- проверить сценарии карты на web end-to-end;
- решить, поддерживается ли web официально, или убрать его из обещаемых платформ.

### 3. Закрыть локализацию

Локализация начата хорошо, но завершена не полностью.

- В проекте есть много `arb`-файлов и generated localizations.
- Но в экранах осталось много жёстко прописанных русских и английских строк, особенно в `stats`, `permissions`, `setup`, `chat detail`, `root`.
- Это значит, что при переключении языка интерфейс останется частично смешанным.

Что нужно сделать:

- вынести все оставшиеся строки в `arb`;
- проверить plural/forms и interpolation;
- пройти все экраны в 2-3 языках и убрать mixed-language UI.

### 4. Нарастить тестовое покрытие

Сейчас это один из самых явных признаков незавершённости.

- Единственный тест находится в [test/widget_test.dart](/Users/imac5/Desktop/baby_locator/test/widget_test.dart:1) и проверяет только запуск `MaterialApp`.
- Нет тестов на auth flow, invite flow, child/parent logic, API client, background commands, stats parsing, safe zones, chat и permissions.

Что нужно сделать:

- unit tests для `ApiClient`, провайдеров и бизнес-логики;
- widget tests для onboarding/auth/settings/core screens;
- integration tests для ключевых сценариев;
- backend tests для auth/tracking/chat API.

### 5. Исправить точечные функциональные и UX-недоработки

Есть несколько мест, которые не выглядят финализированными.

- В [lib/features/child/child_permissions_screen.dart](/Users/imac5/Desktop/baby_locator/lib/features/child/child_permissions_screen.dart:250) и [lib/features/child/child_permissions_screen.dart](/Users/imac5/Desktop/baby_locator/lib/features/child/child_permissions_screen.dart:263) для микрофона и уведомлений открываются location settings, что выглядит как логическая ошибка UX.
- В [lib/features/settings/settings_screen.dart](/Users/imac5/Desktop/baby_locator/lib/features/settings/settings_screen.dart:185) анализатор уже сигнализирует про лишний `?.`.
- Есть warning по неиспользуемому параметру в `children_list_screen.dart`.

Что нужно сделать:

- пройти и исправить все warning-level проблемы;
- сделать ручной smoke-pass по всем permission flows;
- проверить, что каждая кнопка действительно открывает правильные системные настройки.

### 6. Почистить технический долг Flutter

`flutter analyze` показывает **80 issues**. Критичных ошибок нет, но проект всё ещё выглядит недополированным.

Основные типы:

- deprecated API (`withOpacity`, `BitmapDescriptor.fromBytes`);
- `prefer_const_*`;
- ненужные imports;
- один warning на `invalid_null_aware_operator`;
- один warning на `unused_element_parameter`.

Что нужно сделать:

- убрать deprecated API перед следующим обновлением Flutter;
- зачистить analyzer warnings;
- привести код к единым lint-правилам.

### 7. Обновить документацию

README заметно отстаёт от текущего состояния проекта.

Примеры расхождений:

- в root README описана старая структура;
- упоминаются `mock_location_service.dart` и слои, которых уже нет в таком виде;
- написано, что тестов нет, хотя один тест уже есть;
- не описаны многие реальные фичи: Django backend, chat/tasks/rewards, around audio, monitoring, app limits, alerts.

Что нужно сделать:

- переписать основной README под текущую архитектуру;
- добавить разделы "Как запустить client", "Как запустить backend", "Как настроить Firebase", "Как настроить maps", "Как собрать release";
- отдельно описать ограничения Android-only фич.

## Приоритеты до 100%

### P0 — обязательно перед релизом

- production settings для Django;
- release signing и финальный app id;
- env-конфигурация API/maps/tokens;
- исправление web map placeholders или явное снятие web из support matrix;
- smoke-тест всех критичных сценариев на реальных устройствах.

### P1 — очень желательно

- тесты на основные user flows;
- полная локализация;
- закрытие analyzer warnings;
- актуализация README и setup docs.

### P2 — полировка

- косметическая чистка UI/UX;
- рефакторинг повторяющихся строк и helper-методов;
- более формальный release checklist.

## Чек-лист "что осталось"

- [ ] Убрать хардкод окружения и доменов из клиента.
- [ ] Настроить production security для Django.
- [ ] Подготовить Android release config и уникальный application id.
- [ ] Довести или отключить web maps.
- [ ] Исправить permission flows в child permissions screen.
- [ ] Закрыть analyzer warnings и deprecated API.
- [ ] Завершить локализацию интерфейса.
- [ ] Добавить реальное тестовое покрытие client + backend.
- [ ] Переписать README под фактический проект.
- [ ] Провести финальный ручной QA-pass по parent/child сценариям.

## Итог

Если смотреть честно, приложение уже **почти готово функционально**, но ещё **не полностью готово как продукт для уверенного production release**.

До 100% не хватает не "изобрести ещё половину приложения", а:

- довести конфигурацию и релизную инфраструктуру;
- закрыть качество и тестирование;
- выровнять документацию;
- добить web и локализацию;
- убрать несколько точечных логических шероховатостей.

Если нужно, следующим сообщением могу сразу сделать второй файл: **пошаговый план доведения до 100% на 1-2 недели работы с приоритетами по дням**.
