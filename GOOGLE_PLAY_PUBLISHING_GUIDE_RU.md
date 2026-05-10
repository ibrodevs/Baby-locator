# Публикация приложения в Google Play: полный чеклист

Обновлено: 2026-05-09

Этот файл описывает **всё, что нужно сделать**, чтобы подготовить и опубликовать текущее приложение в Google Play и чтобы подписки через RevenueCat работали правильно.

Файл написан именно под этот проект: Flutter-приложение + Django backend + RevenueCat + Google Play subscriptions.

---

## 1. Что уже готово в проекте

На текущий момент в коде уже сделано:

- интеграция RevenueCat в Flutter;
- привязка подписки к backend user ID;
- paywall и restore purchases;
- backend webhook для RevenueCat;
- premium-ограничения во Flutter и Django;
- логика free/premium для детей и карты;
- подготовка Android release-конфига под production.

Это значит, что основная разработка уже выполнена. Дальше нужна **правильная production-настройка** и **публикация через Google Play Console**.

---

## 2. Что обязательно нужно сделать перед публикацией

Перед загрузкой в Google Play нужно закрыть 7 блоков:

1. настроить Android package name;
2. настроить release signing;
3. обновить Firebase Android app и `google-services.json`;
4. задать production-ключи и env;
5. собрать release `.aab`;
6. создать подписки в Google Play;
7. связать Google Play с RevenueCat и протестировать покупку.

### Критично: у этого проекта есть чувствительные Android permissions

Для этого приложения подготовка к публикации не ограничивается сборкой и подписками.
В манифесте уже есть permissions и API, которые в Google Play считаются чувствительными
или высокорисковыми:

- `ACCESS_BACKGROUND_LOCATION`
- `QUERY_ALL_PACKAGES`
- `PACKAGE_USAGE_STATS`
- `AccessibilityService` в Android bridge

Это значит, что перед отправкой в review нужно заранее подготовить:

- корректные in-app disclosures;
- privacy policy;
- точные reviewer instructions;
- permission declaration forms в Play Console;
- при необходимости короткое видео для review, где видно сценарий использования.

Без этого приложение может быть отклонено даже если `.aab` собирается без ошибок.

---

## 3. Подготовка Android-конфига

### 3.1. Задать реальный package name

Сейчас проект позволяет задавать package name через `android/local.properties`.

Есть готовый шаблон:

- [android/local.properties.example](/Users/imac5/Desktop/baby_locator/android/local.properties.example:1)

Сделай копию:

```bash
cp android/local.properties.example android/local.properties
```

Потом заполни:

```properties
sdk.dir=/Users/YOUR_USER/Library/Android/sdk
APP_APPLICATION_ID=com.company.familysecurity
APP_NAMESPACE=com.company.familysecurity
GOOGLE_MAPS_ANDROID_API_KEY=YOUR_ANDROID_MAPS_KEY
```

Что важно:

- `APP_APPLICATION_ID` — это package name, который будет в Google Play;
- он должен быть уникальным;
- после публикации менять его нельзя без публикации нового приложения.

Релевантные файлы:

- [android/local.properties.example](/Users/imac5/Desktop/baby_locator/android/local.properties.example:1)
- [android/app/build.gradle.kts](/Users/imac5/Desktop/baby_locator/android/app/build.gradle.kts:1)

---

## 4. Настройка release signing

Без этого Google Play не примет production release нормально.

### 4.1. Создать upload keystore

Выполни команду:

```bash
keytool -genkeypair -v \
  -keystore ~/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

### 4.2. Создать `android/key.properties`

Есть шаблон:

- [android/key.properties.example](/Users/imac5/Desktop/baby_locator/android/key.properties.example:1)

Сделай копию:

```bash
cp android/key.properties.example android/key.properties
```

Заполни:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Важно:

- `android/key.properties` уже игнорируется git;
- keystore и пароли не коммить;
- без этого release build остановится с ошибкой, и это правильно.

### Альтернатива для CI или локальной сборки без файла

Проект также умеет брать release signing из environment variables:

```bash
ANDROID_KEYSTORE_FILE=/absolute/path/to/upload-keystore.jks
ANDROID_KEYSTORE_PASSWORD=YOUR_STORE_PASSWORD
ANDROID_KEY_ALIAS=upload
ANDROID_KEY_PASSWORD=YOUR_KEY_PASSWORD
```

Это удобно для CI/CD и для случаев, когда не хочется хранить локальный
`android/key.properties`.

---

## 5. Firebase: обновить Android app

Поскольку package name будет production-реальным, нужно обновить Firebase.

### Что сделать

1. Зайди в Firebase Console.
2. Открой проект приложения.
3. Добавь или отредактируй Android app с новым package name:

```text
com.company.familysecurity
```

4. Скачай новый `google-services.json`.
5. Замени файл:

- [android/app/google-services.json](/Users/imac5/Desktop/baby_locator/android/app/google-services.json:1)

### Важно

Если оставить старый `google-services.json` от `com.example.kid_security`, то:

- FCM может работать неправильно;
- Firebase Android app не будет соответствовать release package name;
- в релизе будут ошибки интеграции.

---

## 6. Google Maps API key

В проекте ключ для карт уже используется, но перед продакшеном нужно проверить, что он действительно подходит для нового package name.

Файлы, где он используется:

- [android/local.properties.example](/Users/imac5/Desktop/baby_locator/android/local.properties.example:1)
- [android/app/src/main/AndroidManifest.xml](/Users/imac5/Desktop/baby_locator/android/app/src/main/AndroidManifest.xml:1)

### Что проверить в Google Cloud Console

Если у ключа включены Android restrictions, нужно добавить:

- новый package name;
- SHA-1 или SHA-256 release сертификата.

Иначе в релизе могут не работать:

- Google Maps;
- geocoding;
- reverse geocoding.

### Как получить SHA-1 keystore

```bash
keytool -list -v -keystore /absolute/path/to/upload-keystore.jks -alias upload
```

---

## 7. RevenueCat production key

Для Android release нужно использовать **реальный Android public SDK key** из RevenueCat.

Код это уже поддерживает:

- [lib/core/subscriptions/subscription_service.dart](/Users/imac5/Desktop/baby_locator/lib/core/subscriptions/subscription_service.dart:1)

### Как собирать release

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_API_KEY_ANDROID=YOUR_REAL_ANDROID_REVENUECAT_KEY
```

Не выпускай приложение с test fallback key.

---

## 8. Backend production env

Для продакшена нужно выставить реальные backend env variables.

Шаблон уже подготовлен:

- [backend/.env.pythonanywhere.example](/Users/imac5/Desktop/baby_locator/backend/.env.pythonanywhere.example:1)

### Минимально обязательно заполнить

```env
DJANGO_SECRET_KEY=replace-with-a-long-random-secret
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=your-domain.com,www.your-domain.com
DJANGO_CORS_ALLOW_ALL_ORIGINS=False
DJANGO_CSRF_TRUSTED_ORIGINS=https://your-domain.com

DJANGO_DB_ENGINE=django.db.backends.postgresql
DJANGO_DB_NAME=babydb
DJANGO_DB_USER=babyuser
DJANGO_DB_PASSWORD=replace-with-db-password
DJANGO_DB_HOST=localhost
DJANGO_DB_PORT=5432

REVENUECAT_WEBHOOK_AUTH_HEADER=Bearer very-long-random-secret
REVENUECAT_ENTITLEMENT_ID=family_security_pro
REVENUECAT_PREMIUM_PRODUCT_IDS=monthly,yearly,family_security_pro:monthly,family_security_pro:yearly
REVENUECAT_LIFETIME_PRODUCT_IDS=
```

### Почему это важно

Особенно критично:

- `REVENUECAT_WEBHOOK_AUTH_HEADER` — без него backend не должен принимать production webhooks;
- `REVENUECAT_PREMIUM_PRODUCT_IDS` — для Google Play base plans мы уже учитываем play-style ids;
- `DJANGO_DEBUG=False` — обязателен для production.

---

## 9. Применить миграции на backend

После настройки production окружения нужно применить миграции:

```bash
cd backend
python manage.py migrate
```

Если backend разворачивается на сервере — миграции нужно выполнить именно там.

---

## 10. Создать приложение в Google Play Console

Теперь можно переходить в Google Play Console.

### Что сделать

1. Создай приложение.
2. Заполни базовые данные:
   - app name
   - default language
   - app type
3. Заполни обязательные разделы:
   - App access
   - Ads declaration
   - Content rating
   - Data safety
   - Privacy policy
   - все остальные обязательные поля, которые попросит консоль

### Важно

До публикации подписок и тестов убедись, что Play Console не блокирует тебя незаполненными обязательными разделами.

## 10.1. Отдельно подготовить материалы для Play review

Для этого проекта это обязательно, потому что приложение использует фоновые и
чувствительные Android-возможности.

### Что подготовить заранее

1. Privacy policy URL.
2. App access instructions для ревьюеров:
   - как войти;
   - как создать/выбрать родителя и ребёнка;
   - как открыть экран карты, геозон и блокировки приложений.
3. Короткое reviewer video:
   - как включается background location;
   - как работает геозона;
   - как включается accessibility/app blocking;
   - где пользователь видит disclosure и зачем это нужно.
4. Тексты in-app disclosure до системных permission prompts.

### Что особенно важно для этого приложения

#### Background location

В Play Console нужно будет задекларировать одну главную background-location функцию.
Для этого проекта лучшая кандидатура:

- геозоны / child safety location tracking.

Не надо описывать сразу несколько функций. Для декларации выбери одну core-feature.

#### AccessibilityService

Если app blocking использует accessibility automation, это почти наверняка потребует
отдельной декларации в Play Console и понятного объяснения, что именно делает сервис
и зачем он нужен пользователю.

#### QUERY_ALL_PACKAGES

Если функциональность блокировки приложений реально требует видеть список установленных
приложений на устройстве ребёнка, это нужно будет отдельно обосновать в permission form.
Если можно обойтись более узкой package visibility моделью, Google Play обычно ожидает,
что разработчик уберёт `QUERY_ALL_PACKAGES`.

---

## 11. Создать подписки в Google Play

Открой:

```text
Monetize with Play -> Products -> Subscriptions
```

### Рекомендуемая структура

Создай одну подписку:

- `family_security_pro`

И внутри неё два base plan:

- `monthly`
- `yearly`

### Цены

- Monthly: **5.99 USD**
- Yearly: **29.99 USD**

### Важно

Base plans должны быть:

- активированы;
- доступны в нужных странах;
- привязаны к опубликованной тестовой/боевой сборке приложения.

---

## 12. Подключить Google Play к RevenueCat

Открой RevenueCat project и сделай следующее:

1. Подключи Android app к Google Play.
2. Импортируй продукты из Google Play.
3. Проверь, что появились продукты, похожие на:
   - `family_security_pro:monthly`
   - `family_security_pro:yearly`

### Настроить entitlement

- entitlement id: `family_security_pro`

### Настроить offering

- offering id: `default`

### Настроить packages

Внутри offering `default`:

- monthly package -> monthly product
- annual package -> yearly product

---

## 13. Настроить RevenueCat webhook

Backend endpoint уже есть:

- [backend/subscriptions/views.py](/Users/imac5/Desktop/baby_locator/backend/subscriptions/views.py:1)

Тебе нужно:

1. Задеплоить backend по публичному HTTPS URL.
2. В RevenueCat указать webhook URL:

```text
https://your-domain.com/api/revenuecat/webhook/
```

3. В RevenueCat указать header:

```text
Authorization: Bearer very-long-random-secret
```

4. На backend значение `REVENUECAT_WEBHOOK_AUTH_HEADER` должно быть тем же самым.

---

## 14. Собрать production `.aab`

Когда package name, keystore, Firebase и ключи готовы, собери Android App Bundle:

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_API_KEY_ANDROID=YOUR_REAL_ANDROID_REVENUECAT_KEY
```

Результат будет здесь:

```text
build/app/outputs/bundle/release/app-release.aab
```

---

## 15. Загрузить build в Google Play

Рекомендуемый путь:

- сначала **Internal testing**

### Шаги

1. Открой Google Play Console.
2. Создай Internal testing release.
3. Загрузи `app-release.aab`.
4. Опубликуй internal test release.

Это самый быстрый и безопасный путь для первой проверки покупок.

---

## 16. Добавить тестеров

Чтобы подписки тестировались правильно:

### 16.1. Добавь тестеров в Play test track

Например:

- Internal testing

### 16.2. Добавь тех же людей в License testing

Открой:

```text
Settings -> License testing
```

И добавь Gmail аккаунты тестеров.

### Важно

Если тестер:

- не в test track;
- или не в license testing;
- или не поставил app из Play;

то подписки часто:

- не загружаются;
- не покупаются;
- ведут себя нестабильно.

---

## 17. Первый реальный тест покупки

После публикации internal test release:

1. На Android устройстве войди в Google Play под tester Gmail.
2. Установи приложение из Google Play.
3. Войди в приложение как родитель.
4. Открой paywall.
5. Купи monthly или yearly.

### Потом проверь 4 места

#### В приложении

- premium активировался;
- можно добавить второго ребёнка;
- multi-child map открывается;
- premium функции разблокировались.

#### В RevenueCat

- customer появился;
- `app_user_id` совпадает с backend user id;
- entitlement `family_security_pro` активен.

#### На backend

- webhook пришёл;
- `is_premium=True`;
- `premium_product_id` заполнен.

#### После restore

- `Restore Purchases` работает;
- premium возвращается корректно.

---

## 18. Что проверить перед production release

Перед реальной публикацией в прод:

- package name финальный и правильный
- release signing работает
- Firebase `google-services.json` соответствует package name
- Google Maps key работает с release package + SHA
- RevenueCat Android key production
- backend env production
- webhook настроен
- monthly и yearly созданы в Google Play
- продукты импортированы в RevenueCat
- entitlement `family_security_pro` настроен
- offering `default` настроен
- хотя бы одна реальная test purchase прошла успешно

---

## 19. Частые ошибки

### Подписки не показываются

Обычно причина:

- приложение установлено не из Play test track;
- тестер не добавлен в license testing;
- base plan не активен;
- подписка не импортирована в RevenueCat.

### Покупка проходит, но premium не включается

Обычно причина:

- webhook не доходит;
- `Authorization` header не совпадает;
- backend env не выставлен;
- product ids не сопоставлены.

### Firebase/FCM ломается после смены package name

Причина:

- старый `google-services.json` остался от `com.example.kid_security`.

### Карта ломается в release

Причина:

- Google Maps API key ограничен старым package name или старым SHA.

---

## 20. Самый правильный порядок действий

Делай именно так:

1. создать `android/local.properties`
2. задать `APP_APPLICATION_ID`, `APP_NAMESPACE`, `GOOGLE_MAPS_ANDROID_API_KEY`
3. создать upload keystore
4. создать `android/key.properties`
5. обновить Firebase Android app
6. скачать новый `google-services.json`
7. выставить backend production env
8. выполнить backend migrate
9. собрать `app-release.aab`

10. создать приложение в Google Play Console
11. загрузить `.aab` в Internal testing
12. создать подписку `family_security_pro`
13. создать base plan `monthly` и `yearly`
14. подключить Google Play к RevenueCat
15. импортировать продукты
16. настроить entitlement `family_security_pro`
17. настроить offering `default`
18. настроить webhook
19. добавить тестеров
20. сделать первую тестовую покупку

---

## 21. Полезные файлы в проекте

Android:

- [android/app/build.gradle.kts](/Users/imac5/Desktop/baby_locator/android/app/build.gradle.kts:1)
- [android/app/src/main/AndroidManifest.xml](/Users/imac5/Desktop/baby_locator/android/app/src/main/AndroidManifest.xml:1)
- [android/local.properties.example](/Users/imac5/Desktop/baby_locator/android/local.properties.example:1)
- [android/key.properties.example](/Users/imac5/Desktop/baby_locator/android/key.properties.example:1)

Flutter / RevenueCat:

- [lib/core/subscriptions/subscription_service.dart](/Users/imac5/Desktop/baby_locator/lib/core/subscriptions/subscription_service.dart:1)
- [lib/features/subscription/premium_paywall_screen.dart](/Users/imac5/Desktop/baby_locator/lib/features/subscription/premium_paywall_screen.dart:1)

Backend:

- [backend/config/settings.py](/Users/imac5/Desktop/baby_locator/backend/config/settings.py:1)
- [backend/subscriptions/views.py](/Users/imac5/Desktop/baby_locator/backend/subscriptions/views.py:1)
- [backend/subscriptions/services.py](/Users/imac5/Desktop/baby_locator/backend/subscriptions/services.py:1)
- [backend/.env.pythonanywhere.example](/Users/imac5/Desktop/baby_locator/backend/.env.pythonanywhere.example:1)

---

## 22. Итог

Если коротко:

- код уже почти готов;
- тебе осталось подставить реальные production значения;
- потом пройти стандартную цепочку:
  - Firebase
  - RevenueCat
  - Google Play Console
  - internal testing purchase

После успешной первой test purchase можно считать, что Android publication pipeline готов.
