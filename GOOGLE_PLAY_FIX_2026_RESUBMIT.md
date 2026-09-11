# Baby Locator — исправление отказа Google Play и повторная отправка (2026)

Документ закрывает все 4 замечания из отказа и даёт пошаговую инструкцию по
загрузке. Часть правок — в **коде** (уже сделаны, см. раздел 5), часть — в
**Play Console** (тексты для копирования ниже).

> Пакет приложения (applicationId): по умолчанию `com.company.familysecurity`
> (может быть переопределён через `APP_APPLICATION_ID`). Название в сторе: **Baby Locator**.
> Проверьте фактический package в Play Console → App information.

---

## 0. Кратко: что и где чинить

| # | Замечание Google | Где чинить | Действие |
|---|---|---|---|
| 1 | Общее нарушение правил | — | Закроется автоматически после 2–4 |
| 2 | Нет prominent disclosure для BACKGROUND_LOCATION | Код + Play Console | Disclosure в коде уже корректен; заполнить форму «Разрешения на местоположение» + приложить видео (раздел 2) |
| 3 | AccessibilityService не описан в листинге | Play Console (описание стора) | Вставить блок текста в полное описание (раздел 3) |
| 4 | Не раскрыт тип данных «Адрес» | Play Console (Data Safety) | Добавить **Personal info → Address** в Data Safety (раздел 4) |

---

## 1. Замечание №1 — «Общее нарушение правил»

Это «зонтичное» замечание. Отдельных действий не требует — снимается, когда
исправлены пункты 2, 3 и 4. Просто выполните разделы ниже полностью.

---

## 2. Замечание №2 — Prominent disclosure для фоновой геолокации

### Почему отказали
Google требует, чтобы disclosure появлялся **до любого системного запроса
location**. В прежней версии первый тап «Разрешить местоположение» вызывал
`Geolocator.requestPermission()` напрямую, без disclosure (а `ensurePermission()`
ещё и авто-запрашивал разрешение). Поэтому системный запрос мог появиться раньше
нашего экрана раскрытия.

### Что исправлено в коде (см. раздел 5.1)
- `LocationService.ensurePermission()` больше не показывает системный запрос —
  только проверяет статус.
- Единственная точка запроса foreground-геолокации — новый
  `requestForegroundPermission()`, вызывается **только после принятого disclosure**.
- `child_permissions_screen._requestLocationPermission()` теперь сначала показывает
  `BackgroundLocationDisclosureDialog`, и лишь затем — системный запрос.
- Текст disclosure содержит все обязательные элементы Google: «собирает данные о
  местоположении, даже когда приложение закрыто, работает в фоне или не
  используется», перечень функций, и что данные не используются для рекламы и не
  продаются.

### Что сделать в Play Console (обязательно)
1. **App content → Sensitive app permissions → Location permissions** (Доступ к
   местоположению) — заполнить декларацию:
   - Отметить, что приложение использует фоновую геолокацию.
   - **Основная функция**, требующая фоновой геолокации: отслеживание местоположения
     ребёнка родителем в реальном времени, уведомления о входе/выходе из безопасных
     зон, координаты при SOS.
   - Приложить **видео** (ссылка на YouTube, «не в списке»/unlisted), где показано:
     запуск → экран ребёнка → появляется prominent disclosure → пользователь
     соглашается → системный запрос «Разрешать всегда». Скрипт видео — в
     `GOOGLE_PLAY_REVIEW_VIDEOS.md`.
2. **App access** (Доступ к приложению) — указать тестовые аккаунты (см. раздел 6),
   чтобы проверяющий смог дойти до экрана ребёнка и увидеть disclosure.

### Текст для поля «Обоснование фоновой геолокации» (копировать)
```text
Baby Locator is a parental safety app. The child device runs a foreground service
that reports its location to the linked parent so the parent can see the child's
real-time position on a live map, receive Safe Zone (Home/School) enter/exit
notifications, and receive exact coordinates when the child presses the SOS button.
These features require location access while the app is in the background or the
screen is locked. Before requesting "Allow all the time", the app shows an in-app
prominent disclosure explaining that location is collected in the background, listing
the exact features, and stating that data is transmitted over encrypted HTTPS, is
visible only to the paired parent account, and is never used for advertising or sold.
```

---

## 3. Замечание №3 — AccessibilityService не описан в листинге стора

### Почему отказали
Приложение использует AccessibilityService API (для блокировки приложений на
устройстве ребёнка), но в **описании на странице Google Play** это не раскрыто.
Google требует, чтобы использование Accessibility было описано именно в тексте
листинга (Store listing → Full description), а не только внутри приложения.

### Что сделать
**Play Console → Store presence → Main store listing → Full description** — добавьте
в конец описания следующий блок (RU + EN). После сохранения — **пересоздать релиз не
нужно**, это листинг; но менять его лучше синхронно с новым релизом.

### Текст для полного описания (копировать; RU)
```text
─────────────────────────
Использование специальных возможностей (AccessibilityService)

Baby Locator использует Android AccessibilityService API исключительно для функции
родительского контроля «Блокировка приложений» на устройстве ребёнка и только после
явного согласия в приложении. Сервис определяет имя пакета (package name) активного
приложения на переднем плане, чтобы закрывать приложения, ограниченные родителем, и
соблюдать правила экранного времени. Сервис НЕ читает, не собирает и не передаёт
текст с экрана, личные сообщения, пароли, нажатия клавиш, фотографии или платёжные
данные. Определение пакета выполняется локально на устройстве.
```

### Текст для полного описания (копировать; EN — если есть англоязычный листинг)
```text
─────────────────────────
Accessibility (AccessibilityService) usage

Baby Locator uses the Android AccessibilityService API solely for the parental
"App Blocking" / screen-time feature on the child device, and only after explicit
in-app consent. The service reads the package name of the current foreground app to
close parent-restricted apps and enforce screen-time rules. It does NOT read, collect,
or transmit screen text, private messages, passwords, keystrokes, photos, or payment
data. Package-name detection runs locally on the device.
```

### Форма декларации Accessibility (App content → Accessibility)
Ответы для формы — в файле `GOOGLE_PLAY_ACCESSIBILITY_DECLARATION.md` (обновите там
название на **Baby Locator** и актуальный package). Ключевое:
- Это НЕ инструмент для людей с ограниченными возможностями.
- API: **AccessibilityService**.
- Назначение: **родительский контроль / блокировка приложений**.
- Prominent disclosure перед запросом: **Да** (экран
  `AccessibilityDisclosureDialog`, показывается перед открытием системных настроек).

---

## 4. Замечание №4 — Не раскрыт тип данных «Адрес»

### Почему отказали
Приложение обрабатывает **физический адрес**: координаты ребёнка преобразуются в
уличный адрес (обратное геокодирование) для истории и показа родителю; безопасные
зоны (Дом/Школа) тоже хранят адрес. В таксономии Google Data Safety «Адрес» — это
тип данных **Personal info → Address**, и он не был указан.

> Важно: сам AccessibilityService адрес НЕ собирает (он читает только package name).
> «Адрес» появляется из геолокации. Поэтому в форме Accessibility поле «какие данные
> собирает accessibility» оставляем **None/Нет**, а «Адрес» декларируем в общей форме
> **Data Safety**.

### Что сделать: Play Console → App content → Data safety
Убедитесь, что задекларированы все реально собираемые типы. Минимально для этого
приложения:

| Категория | Тип данных | Collected | Shared | Назначение | Обязательно? |
|---|---|---|---|---|---|
| Location | Precise location | Да | Нет | App functionality (отслеживание ребёнка родителем) | Обязательно для работы |
| Location | Approximate location | Да | Нет | App functionality | Обязательно |
| **Personal info** | **Address** | **Да** | Нет | App functionality (история адресов, безопасные зоны) | Можно сделать опциональным |
| Personal info | Name / User IDs | Да | Нет | Account management | По факту |
| Messages (если есть чат) | In-app messages | Да | Нет | App functionality | По факту |
| Audio | Voice or sound recordings | Да | Нет | App functionality («Слушать вокруг» — стрим родителю, не хранится) | По факту |

Для каждого типа укажите: **шифруется при передаче — Да**; **можно ли запросить
удаление — Да** (у вас есть удаление аккаунта). Приведите форму в соответствие с
`privacy-policy.html`.

### Ключевое действие по замечанию №4
Добавьте **Personal info → Address**: Collected = Yes, Shared = No, Purpose =
App functionality (+ при желании отметить как «опциональные» данные). Это снимает
замечание про «Адрес».

---

## 5. Что уже исправлено в коде (этот коммит)

### 5.1 Background Location — disclosure теперь ГАРАНТИРОВАННО до запроса (главный blocker №2)
**Что было не так:** на детском экране разрешений первый тап «Разрешить
местоположение» вызывал `Geolocator.requestPermission()` **напрямую, без
disclosure**. Плюс `LocationService.ensurePermission()` сам авто-запрашивал
разрешение. Значит системный запрос location мог появиться раньше нашего экрана
раскрытия — это и есть причина отказа Google.

**Фикс (сделан):**
- `LocationService.ensurePermission()` теперь **только проверяет** статус и НИКОГДА
  не показывает системный запрос (убран авто-`requestPermission()`).
- Добавлен явный `LocationService.requestForegroundPermission()` — единственная
  точка, которая показывает системный запрос foreground-геолокации, и вызывается
  только из UI после принятого disclosure.
- `child_permissions_screen._requestLocationPermission()`: теперь сначала
  `BackgroundLocationDisclosureDialog.show(...)`, и только при согласии — запрос.
- Фоновый запрос (`_requestBackgroundLocation`) как и раньше идёт после disclosure.

Итог: **ни один экран не может вызвать системный запрос location раньше нашего
disclosure.** Порядок теперь: тап → наш экран раскрытия → «Согласен» → системный
запрос Android.

**Файлы:**
- `lib/core/services/location_service.dart`
- `lib/features/child/child_permissions_screen.dart`

### 5.2 Accessibility и микрофон — disclosure без изменений
Экраны disclosure (accessibility, микрофон) уже соответствуют правилам. Правок кода
не требуется — только заполнение форм/листинга Play Console (разделы 3–4).

### 5.3 Версия
`pubspec.yaml`: `1.0.7+14` (versionCode 14). Play требует, чтобы versionCode рос.

---

## 6. Тестовые аккаунты для проверяющего (Play Console → App access)

Уже описаны в `GOOGLE_PLAY_REVIEWER_ACCESS.md`. Убедитесь, что аккаунты **реально
существуют на бэкенде** и привязаны:

```bash
# на сервере, в каталоге бэкенда:
python3 manage.py create_play_review_accounts
```

В Play Console → **App access** выберите «All or some functionality is restricted» и
добавьте инструкции + логин/пароль родителя и ребёнка. Приложите короткое видео
прохождения (сценарии A–F из reviewer-гайда), особенно **сценарий с disclosure
геолокации** и **сценарий «Слушать вокруг»**.

---

## 7. Серверная часть — для этой отправки НЕ требуется

Все исправления по 4 замечаниям — это код приложения (раздел 5.1) + формы Play
Console (разделы 2–4). Деплой бэкенда для прохождения ревью **не нужен**.

> Функция «Слушать вокруг» (WebRTC) — отдельная тема, к 4 причинам отказа не
> относится. Чтобы она стабильно работала, нужны Firebase-ключ на сервере и TURN —
> см. отдельный файл `LISTEN_AROUND_FIX.md`. На одобрение в Google Play это не влияет.

---

## 8. Сборка релизного AAB (клиент)

```bash
cd "Baby-locator"

# 1) зависимости и кодоген локализаций
flutter pub get

# 2) чистая сборка релизного App Bundle (подпись берётся из key.properties)
flutter clean
flutter build appbundle --release

# Итоговый файл:
#   build/app/outputs/bundle/release/app-release.aab
```

Проверьте, что versionCode = 14 (`1.0.7+14`) и что подпись — вашим upload-ключом
(см. `RELEASE_AAB_VERIFICATION.md`).

---

## 9. Порядок повторной отправки в Google Play (пошагово)

1. **Соберите AAB** (раздел 8), versionCode 14. Деплой бэкенда для ревью не нужен.
3. Play Console → **App content**:
   - **Data safety** → добавьте **Personal info → Address** и приведите форму в
     соответствие (раздел 4). Сохраните и отправьте.
   - **Sensitive app permissions → Location** → заполните декларацию фоновой
     геолокации + видео (раздел 2). Сохраните.
   - **Accessibility** → заполните форму (раздел 3, файл-шаблон
     `GOOGLE_PLAY_ACCESSIBILITY_DECLARATION.md`). Сохраните.
   - **App access** → тестовые аккаунты + инструкции (раздел 6).
4. Play Console → **Store presence → Main store listing → Full description** →
   вставьте блок про AccessibilityService (раздел 3). Сохраните.
5. Play Console → **Production** (или ваш трек тестирования) → **Create new release**
   → загрузите `app-release.aab` (versionCode 14) → заполните release notes →
   **Review release**.
6. Убедитесь, что **все формы App content имеют статус «зелёный/complete»** — иначе
   релиз не уйдёт на проверку.
7. **Start rollout / Send for review**.
8. Ожидайте результат. Если снова отклонят по тому же пункту — в письме будет ссылка
   на конкретный экран/форму; проверьте, что видео действительно показывает
   disclosure и что тестовые аккаунты рабочие.

### Release notes (пример, RU)
```text
• Экран раскрытия информации теперь показывается до запроса доступа к геолокации.
• Обновлены уведомления о конфиденциальности и раскрытие данных.
• Исправления и улучшения стабильности.
```

---

## 10. Чек-лист перед отправкой

- [ ] AAB собран из нового кода, versionCode = 14 (disclosure до запроса location).
- [ ] Проверено на устройстве: тап «Разрешить местоположение» → сначала наш экран
      раскрытия, только потом системный запрос Android.
- [ ] Data safety: добавлен **Address**, всё «complete».
- [ ] Декларация фоновой геолокации заполнена + видео приложено.
- [ ] Форма Accessibility заполнена.
- [ ] В полное описание добавлен блок про AccessibilityService.
- [ ] App access: тестовые аккаунты рабочие и указаны.
- [ ] Privacy policy (`privacy-policy.html`) соответствует формам.
