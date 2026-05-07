// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Войдите или создайте родительский аккаунт';

  @override
  String get signIn => 'Войти';

  @override
  String get createParentAccount => 'Создать родительский аккаунт';

  @override
  String get childrenSignInHint =>
      'Дети входят с учётными данными, созданными их родителем.';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get navMap => 'Карта';

  @override
  String get navActivity => 'Активность';

  @override
  String get navChat => 'Чат';

  @override
  String get navStats => 'Статистика';

  @override
  String get navHome => 'Главная';

  @override
  String get waitingForLocation => 'Ожидание геолокации от детей...';

  @override
  String get addChildToTrack => 'Добавьте ребёнка для начала отслеживания';

  @override
  String get manageChildren => 'Управление детьми';

  @override
  String get loud => 'ГРОМКО';

  @override
  String get around => 'ВОКРУГ';

  @override
  String get currentLocation => 'ТЕКУЩЕЕ МЕСТОПОЛОЖЕНИЕ';

  @override
  String messageChild(String childName) {
    return 'Написать $childName';
  }

  @override
  String get history => 'История';

  @override
  String lastUpdated(String time) {
    return 'Обновлено: $time';
  }

  @override
  String get statusActive => 'АКТИВЕН';

  @override
  String get statusPaused => 'НА ПАУЗЕ';

  @override
  String get statusOffline => 'ОФЛАЙН';

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(int minutes) {
    return '$minutes мин. назад';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ч. назад';
  }

  @override
  String get active => 'Активен';

  @override
  String get inactive => 'Неактивен';

  @override
  String get addChildToSeeActivity =>
      'Добавьте ребёнка для просмотра активности';

  @override
  String get activity => 'Активность';

  @override
  String get today => 'Сегодня';

  @override
  String get leftArea => 'Покинул зону';

  @override
  String get arrivedAtLocation => 'Прибыл в место';

  @override
  String get phoneCharging => 'Телефон заряжается';

  @override
  String batteryReached(int battery) {
    return 'Заряд батареи достиг $battery%';
  }

  @override
  String get batteryLow => 'Низкий заряд батареи';

  @override
  String batteryDropped(int battery) {
    return 'Заряд батареи упал до $battery%';
  }

  @override
  String get currentLocationTitle => 'Текущее местоположение';

  @override
  String get locationShared => 'Местоположение передано';

  @override
  String get batteryStatus => 'Статус батареи';

  @override
  String batteryAt(int battery) {
    return 'Батарея: $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Активности пока нет. События появятся, когда $childName поделится местоположением.';
  }

  @override
  String get safeZones => 'Места';

  @override
  String get addNew => 'Добавить';

  @override
  String get noSafeZonesYet => 'Мест пока нет';

  @override
  String zone(String zoneName) {
    return 'Место: $zoneName';
  }

  @override
  String get editZone => 'Редактировать место';

  @override
  String get activeToday => 'АКТИВНА СЕГОДНЯ';

  @override
  String get inactiveToday => 'НЕАКТИВНА СЕГОДНЯ';

  @override
  String get disabled => 'ОТКЛЮЧЕНА';

  @override
  String get dailySafetyScore => 'Ежедневный индекс безопасности';

  @override
  String get noLocationUpdatesYet => 'Обновлений местоположения за сегодня нет';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates из $totalUpdates обновлений сегодня были в безопасных зонах';
  }

  @override
  String coverage(int percent) {
    return 'Охват: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Текущее место: $zoneName';
  }

  @override
  String get addSafeZone => 'Добавить новое место';

  @override
  String get editSafeZone => 'Редактировать место';

  @override
  String get deleteZoneTitle => 'Удалить место?';

  @override
  String get deleteZoneMessage => 'Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get zoneEnabled => 'МЕСТО АКТИВНО';

  @override
  String get zoneName => 'НАЗВАНИЕ МЕСТА';

  @override
  String get zoneNameHint => 'например, Дом, Школа';

  @override
  String get activeWhen => 'АКТИВНА КОГДА';

  @override
  String get always => 'Всегда';

  @override
  String get daysOfWeek => 'Дни недели';

  @override
  String get chooseAtLeastOneDay =>
      'Выберите хотя бы один день для этого расписания.';

  @override
  String get radius => 'РАДИУС';

  @override
  String get locationMoveMap =>
      'МЕСТОПОЛОЖЕНИЕ (Переместите карту, чтобы установить метку)';

  @override
  String get moveMapToSetCenter =>
      'Переместите карту, чтобы установить центр места';

  @override
  String get createSafeZone => 'Создать место';

  @override
  String get updateSafeZone => 'Обновить место';

  @override
  String get pleaseEnterZoneName => 'Пожалуйста, введите название места';

  @override
  String get chooseAtLeastOneDayError => 'Выберите хотя бы один активный день';

  @override
  String get addChildToChat => 'Добавьте ребёнка для начала общения';

  @override
  String get noMessagesYet => 'Сообщений пока нет. Поздоровайтесь!';

  @override
  String get sendMessage => 'Написать сообщение...';

  @override
  String failedToSend(String error) {
    return 'Не удалось отправить: $error';
  }

  @override
  String helloUser(String name) {
    return 'Привет, $name!';
  }

  @override
  String get kidMode => 'Режим ребёнка';

  @override
  String get myLocation => 'Моё местоположение';

  @override
  String get waitingForGps => 'Ожидание GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Передано родителю · $time';
  }

  @override
  String get notSharedYet => 'Ещё не передано';

  @override
  String get imSafe => 'Я в безопасности';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Родителю отправлено «Я в безопасности»';

  @override
  String get sosMessage => 'SOS! Мне нужна помощь!';

  @override
  String sosLocation(String address) {
    return ' Местоположение: $address';
  }

  @override
  String get sosSent => 'SOS отправлен — родитель будет уведомлён';

  @override
  String get allowUsageAccess => 'Разрешить доступ к статистике использования';

  @override
  String get usageAccessDescription =>
      'Это позволяет родительской панели отображать реальные данные об экранном времени и ограничения приложений с этого телефона.';

  @override
  String get openUsageAccess => 'Открыть доступ к статистике';

  @override
  String syncError(String error) {
    return 'Ошибка синхронизации: $error';
  }

  @override
  String get iphoneLimitation => 'Ограничение iPhone';

  @override
  String get iphoneUsageDescription =>
      'На iPhone нет экрана доступа к статистике использования в стиле Android. Реальное экранное время по приложениям и прямая блокировка приложений требуют API Apple Screen Time и специальных прав, поэтому эта кнопка не работает на iOS.';

  @override
  String get turnOnLocation => 'Включить службы геолокации';

  @override
  String get locationIsOff =>
      'Геолокация отключена. Включите её для передачи родителю.';

  @override
  String get openLocationSettings => 'Открыть настройки геолокации';

  @override
  String get locationBlocked => 'Доступ к геолокации заблокирован';

  @override
  String get enableLocationAccess =>
      'Включите доступ к геолокации в настройках системы.';

  @override
  String get openAppSettings => 'Открыть настройки приложения';

  @override
  String get allowLocationToShare => 'Разрешите геолокацию для передачи данных';

  @override
  String get grantLocationPermission =>
      'Предоставьте разрешение, чтобы родитель мог видеть, где вы находитесь.';

  @override
  String get allowLocation => 'Разрешить геолокацию';

  @override
  String get myChildren => 'Мои дети';

  @override
  String get addChild => 'Добавить ребёнка';

  @override
  String get noChildrenYet =>
      'Детей пока нет. Нажмите «Добавить ребёнка», чтобы создать профиль.';

  @override
  String get parentAccount => 'Родительский аккаунт';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get deleteChildTitle => 'Удалить ребёнка?';

  @override
  String deleteChildMessage(String childName) {
    return 'Удалить $childName и всю связанную историю активности?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName удалён';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Не удалось удалить ребёнка: $error';
  }

  @override
  String get avatarUpdated => 'Аватар обновлён';

  @override
  String failedGeneric(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get createChildAccount => 'Создать аккаунт ребёнка';

  @override
  String get childSignInHint =>
      'Ваш ребёнок войдёт с этими данными на своём устройстве.';

  @override
  String get displayNameHint => 'Отображаемое имя (например, Алекс)';

  @override
  String get create => 'Создать';

  @override
  String get editChildProfile => 'Редактировать профиль ребёнка';

  @override
  String get save => 'Сохранить';

  @override
  String get deleteChild => 'Удалить ребёнка';

  @override
  String get track => 'Отслеживать';

  @override
  String get edit => 'Редактировать';

  @override
  String get settings => 'Настройки';

  @override
  String get parent => 'РОДИТЕЛЬ';

  @override
  String get child => 'РЕБЁНОК';

  @override
  String get editProfileDetails => 'Редактировать данные профиля';

  @override
  String get account => 'Аккаунт';

  @override
  String get manageChildrenMenu => 'Управление детьми';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get locationAlerts => 'Уведомления о местоположении';

  @override
  String get batteryAlerts => 'Уведомления о батарее';

  @override
  String get safeZoneAlerts => 'Уведомления о местах';

  @override
  String get notificationPermissionRequired =>
      'Для отправки уведомлений необходимо разрешение';

  @override
  String get general => 'Общее';

  @override
  String get language => 'Язык';

  @override
  String get systemDefault => 'Системный язык';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get about => 'О приложении';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get signOut => 'Выйти';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get updateProfileHint =>
      'Обновите отображаемое имя и имя пользователя.';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get usernameCannotBeEmpty => 'Имя пользователя не может быть пустым';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String failedToUploadAvatar(String error) {
    return 'Не удалось загрузить аватар: $error';
  }

  @override
  String get parentProfile => 'Профиль родителя';

  @override
  String get addChildForStats =>
      'Сначала добавьте аккаунт ребёнка для просмотра статистики.';

  @override
  String get insights => 'АНАЛИТИКА';

  @override
  String childStats(String childName) {
    return 'Статистика $childName';
  }

  @override
  String get deviceStatus => 'Статус устройства';

  @override
  String batteryPercent(int battery) {
    return 'Батарея $battery%';
  }

  @override
  String get batteryUnknown => 'Заряд неизвестен';

  @override
  String synced(String time) {
    return 'Синхронизировано $time';
  }

  @override
  String get noDeviceSyncYet => 'Синхронизации ещё не было';

  @override
  String get usageAccessGranted => 'Доступ к статистике предоставлен';

  @override
  String get usageAccessNeeded => 'Требуется доступ к статистике';

  @override
  String get iosUsageAccessNote =>
      'Это устройство ребёнка — iPhone. iOS не предоставляет доступ к статистике использования в стиле Android, поэтому приложение не может открыть этот экран разрешений. Реальное экранное время на iPhone и блокировка приложений требуют прав Apple Screen Time и отдельной нативной интеграции.';

  @override
  String get androidUsageAccessNote =>
      'Откройте приложение для ребёнка на телефоне и разрешите доступ к статистике использования. После этого экранное время, ограничения приложений и календарь будут синхронизироваться автоматически.';

  @override
  String get dailyUsage => 'Использование за день';

  @override
  String usageOfLimit(String total, String limit) {
    return 'Использовано $total из $limit';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total использовано $date';
  }

  @override
  String get allLimitsInRange => 'Все активные ограничения в норме';

  @override
  String appLimitExceeded(int count) {
    return 'Сегодня превышено $count ограничение приложений';
  }

  @override
  String get setAppLimitsHint =>
      'Установите ограничения приложений ниже, чтобы превратить это в реальную цель.';

  @override
  String get weeklyUsage => 'Использование за неделю';

  @override
  String get usageCalendar => 'Календарь использования';

  @override
  String get noAppUsageData =>
      'Данных об использовании приложений за этот день пока нет.';

  @override
  String get grantUsageAccessHint =>
      'Предоставьте доступ к статистике на телефоне ребёнка для просмотра данных и управления ограничениями.';

  @override
  String get iosAppLimitsUnavailable =>
      'Телефон ребёнка — iPhone. Текущая версия приложения не имеет интеграции с Apple Screen Time, поэтому реальное использование приложений и прямые ограничения недоступны на iOS.';

  @override
  String get enableDailyLimit => 'Включить дневной лимит';

  @override
  String get dailyLimit => 'Дневной лимит';

  @override
  String get saveLimit => 'Сохранить лимит';

  @override
  String get manageAppLimits => 'Управление ограничениями приложений';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName использовалось $date';
  }

  @override
  String limitMinutes(String time) {
    return 'Лимит $time';
  }

  @override
  String get noLimit => 'Без ограничений';

  @override
  String usageTodayOverLimit(String time) {
    return '$time сегодня · лимит превышен';
  }

  @override
  String usageToday(String time) {
    return '$time сегодня';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Лимит сохранён для $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Лимит отключён для $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Не удалось сохранить лимит: $error';
  }

  @override
  String get mon => 'ПН';

  @override
  String get tue => 'ВТ';

  @override
  String get wed => 'СР';

  @override
  String get thu => 'ЧТ';

  @override
  String get fri => 'ПТ';

  @override
  String get sat => 'СБ';

  @override
  String get sun => 'ВС';

  @override
  String get over => 'ПРЕВЫШЕН';

  @override
  String get onboardingTitle => 'Добро пожаловать!';

  @override
  String get onboardingSubtitle => 'Кто вы?';

  @override
  String get iAmParent => 'Я родитель';

  @override
  String get iAmChild => 'Я ребёнок';

  @override
  String get parentSignIn => 'Войти';

  @override
  String get parentCreateAccount => 'Создать аккаунт';

  @override
  String get parentAuthSubtitle => 'Управляйте и защищайте свою семью';

  @override
  String get childSignIn => 'Войти';

  @override
  String get childAuthTitle => 'Привет!';

  @override
  String get childAuthSubtitle => 'Попросите у родителя код приглашения';

  @override
  String get childNavSettings => 'Настройки';

  @override
  String get childProfile => 'Профиль';

  @override
  String get childSettingsTitle => 'Настройки';

  @override
  String get childLogout => 'Выйти';

  @override
  String get inviteChild => 'Пригласить ребёнка';

  @override
  String get inviteTitle => 'Пригласите детей и других членов семьи в ваш круг';

  @override
  String get inviteSubtitle =>
      'Вашим близким необходимо установить приложение и присоединиться к кругу, используя код';

  @override
  String get inviteCodeLabel => 'Код действует 3 дня';

  @override
  String get shareCode => 'Поделиться кодом';

  @override
  String get getHelp => 'Получить помощь';

  @override
  String get generateCode => 'Сгенерировать код';

  @override
  String get codeCopied => 'Код скопирован в буфер обмена';

  @override
  String inviteShareText(String code) {
    return 'Присоединяйся к моему семейному кругу в Family security! Используй код приглашения: $code\n\nhttp://89.108.81.151/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Не удалось сгенерировать код: $error';
  }

  @override
  String get childRegisterTitle => 'Присоединиться к семье';

  @override
  String get childRegisterSubtitle => 'Введите код приглашения от родителя';

  @override
  String get inviteCode => 'Код приглашения';

  @override
  String get next => 'Далее';

  @override
  String get setupYourProfile => 'Настройте свой профиль';

  @override
  String get enterYourDetails => 'Введите отображаемое имя';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get invalidInviteCode => 'Неверный или просроченный код приглашения';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get dontHaveCode => 'Есть код приглашения? Зарегистрироваться';

  @override
  String get placesOnMap => 'Места на карте';

  @override
  String get placesAndChildren => 'Места и дети';

  @override
  String placesCount(int count) {
    return 'Мест: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Активны сегодня: $count';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get createPlaceHint =>
      'Создайте место, чтобы получать уведомления, когда ребёнок приходит или уходит.';

  @override
  String get untitledPlace => 'Без названия';

  @override
  String get placeDeleted => 'Место удалено.';

  @override
  String get editLabel => 'Изменить';

  @override
  String get disabledSchedule => 'Выключено';

  @override
  String get noDaysSelected => 'Дни не выбраны';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Радиус $radius • $schedule';
  }
}
