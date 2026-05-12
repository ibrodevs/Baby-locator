// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class SKk extends S {
  SKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Кіріңіз немесе ата-ана аккаунтын жасаңыз';

  @override
  String get signIn => 'Кіру';

  @override
  String get createParentAccount => 'Ата-ана аккаунтын жасау';

  @override
  String get childrenSignInHint =>
      'Балалар ата-анасы жасаған деректермен кіреді.';

  @override
  String get createAccount => 'Аккаунт жасау';

  @override
  String get displayName => 'Көрсетілетін атау';

  @override
  String get username => 'Пайдаланушы аты';

  @override
  String get password => 'Құпия сөз';

  @override
  String get navMap => 'Карта';

  @override
  String get navActivity => 'Белсенділік';

  @override
  String get navChat => 'Чат';

  @override
  String get navStats => 'Статистика';

  @override
  String get navHome => 'Басты бет';

  @override
  String get waitingForLocation => 'Балалардың орналасқан жерін күтуде...';

  @override
  String get addChildToTrack => 'Қадағалауды бастау үшін бала қосыңыз';

  @override
  String get manageChildren => 'Балаларды басқару';

  @override
  String get loud => 'ҚАТТЫ';

  @override
  String get around => 'АЙНАЛА';

  @override
  String get currentLocation => 'АҒЫМДАҒЫ ОРЫН';

  @override
  String messageChild(String childName) {
    return '$childName-ға хабар жіберу';
  }

  @override
  String get history => 'Тарих';

  @override
  String lastUpdated(String time) {
    return 'Жаңартылды: $time';
  }

  @override
  String get statusActive => 'БЕЛСЕНДІ';

  @override
  String get statusPaused => 'ТОҚТАТЫЛДЫ';

  @override
  String get statusOffline => 'ОФЛАЙН';

  @override
  String get justNow => 'Дәл қазір';

  @override
  String minutesAgo(int minutes) {
    return '$minutes мин. бұрын';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours сағ. бұрын';
  }

  @override
  String get active => 'Белсенді';

  @override
  String get inactive => 'Белсенді емес';

  @override
  String get addChildToSeeActivity => 'Белсенділікті көру үшін бала қосыңыз';

  @override
  String get activity => 'Белсенділік';

  @override
  String get today => 'Бүгін';

  @override
  String get leftArea => 'Аймақтан шықты';

  @override
  String get arrivedAtLocation => 'Орынға жетті';

  @override
  String get phoneCharging => 'Телефон зарядталуда';

  @override
  String batteryReached(int battery) {
    return 'Батарея заряды $battery%-ға жетті';
  }

  @override
  String get batteryLow => 'Батарея заряды аз';

  @override
  String batteryDropped(int battery) {
    return 'Батарея заряды $battery%-ға дейін төмендеді';
  }

  @override
  String get currentLocationTitle => 'Ағымдағы орын';

  @override
  String get locationShared => 'Орналасқан жер жіберілді';

  @override
  String get batteryStatus => 'Батарея күйі';

  @override
  String batteryAt(int battery) {
    return 'Батарея: $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Белсенділік жоқ. $childName орналасқан жерін жіберген соң оқиғалар пайда болады.';
  }

  @override
  String get safeZones => 'Орындар';

  @override
  String get addNew => 'Жаңа қосу';

  @override
  String get noSafeZonesYet => 'Әзірге орындар жоқ';

  @override
  String zone(String zoneName) {
    return 'Орын: $zoneName';
  }

  @override
  String get editZone => 'Орынды өңдеу';

  @override
  String get activeToday => 'БҮГІН БЕЛСЕНДІ';

  @override
  String get inactiveToday => 'БҮГІН БЕЛСЕНДІ ЕМЕС';

  @override
  String get disabled => 'ӨШІРІЛГЕН';

  @override
  String get dailySafetyScore => 'Күнделікті қауіпсіздік көрсеткіші';

  @override
  String get noLocationUpdatesYet => 'Бүгін орын жаңартулары жоқ';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return 'Бүгін $totalUpdates жаңартудың $inZoneUpdates-і қауіпсіз аймақтарда болды';
  }

  @override
  String coverage(int percent) {
    return 'Қамту: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Қазіргі орын: $zoneName';
  }

  @override
  String get addSafeZone => 'Жаңа орын қосу';

  @override
  String get editSafeZone => 'Орынды өңдеу';

  @override
  String get deleteZoneTitle => 'Орын жойылсын ба?';

  @override
  String get deleteZoneMessage => 'Бұл әрекетті болдырмауға болмайды.';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get delete => 'Жою';

  @override
  String get zoneEnabled => 'ОРЫН БЕЛСЕНДІ';

  @override
  String get zoneName => 'ОРЫН АТАУЫ';

  @override
  String get zoneNameHint => 'мысалы, Үй, Мектеп';

  @override
  String get activeWhen => 'БЕЛСЕНДІ БОЛҒАНДА';

  @override
  String get always => 'Әрқашан';

  @override
  String get daysOfWeek => 'Апта күндері';

  @override
  String get chooseAtLeastOneDay => 'Бұл кестеге кем дегенде бір күн таңдаңыз.';

  @override
  String get radius => 'РАДИУС';

  @override
  String get locationMoveMap =>
      'ОРНАЛАСУ (Орталық нүктені қою үшін картаны жылжытыңыз)';

  @override
  String get moveMapToSetCenter =>
      'Орынның ортасын белгілеу үшін картаны жылжытыңыз';

  @override
  String get createSafeZone => 'Орын жасау';

  @override
  String get updateSafeZone => 'Орынды жаңарту';

  @override
  String get pleaseEnterZoneName => 'Орын атауын енгізіңіз';

  @override
  String get chooseAtLeastOneDayError =>
      'Кем дегенде бір белсенді күн таңдаңыз';

  @override
  String get addChildToChat => 'Чатты бастау үшін бала қосыңыз';

  @override
  String get noMessagesYet => 'Хабарлар жоқ. Сәлем айтыңыз!';

  @override
  String get sendMessage => 'Хабар жіберу...';

  @override
  String failedToSend(String error) {
    return 'Жіберілмеді: $error';
  }

  @override
  String helloUser(String name) {
    return 'Сәлем, $name!';
  }

  @override
  String get kidMode => 'Бала режимі';

  @override
  String get myLocation => 'Менің орным';

  @override
  String get waitingForGps => 'GPS күтуде...';

  @override
  String sharedWithParent(String time) {
    return 'Ата-анаға жіберілді · $time';
  }

  @override
  String get notSharedYet => 'Әлі жіберілмеді';

  @override
  String get imSafe => 'Мен қауіпсіздікте';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Ата-анаңа «Мен қауіпсіздікте» хабары жіберілді';

  @override
  String get sosMessage => 'SOS! Маған көмек керек!';

  @override
  String sosLocation(String address) {
    return ' Орын: $address';
  }

  @override
  String get sosSent => 'SOS жіберілді — ата-ана хабарландырылады';

  @override
  String get allowUsageAccess => 'Пайдалану статистикасына рұқсат беру';

  @override
  String get usageAccessDescription =>
      'Бұл ата-ана бақылау тақтасына осы телефондағы экран уақытының нақты деректерін және қолданба шектеулерін көрсетуге мүмкіндік береді.';

  @override
  String get openUsageAccess => 'Пайдалану статистикасын ашу';

  @override
  String syncError(String error) {
    return 'Синхрондау қатесі: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone шектеуі';

  @override
  String get iphoneUsageDescription =>
      'iPhone-да Android-тегідей пайдалану статистикасы экраны жоқ. Қолданба бойынша нақты экран уақыты мен тікелей блоктау Apple Screen Time API және арнайы құқықтарды қажет етеді, сондықтан бұл түйме iOS-та жұмыс істемейді.';

  @override
  String get turnOnLocation => 'Геолокация қызметтерін қосу';

  @override
  String get locationIsOff =>
      'Геолокация өшірулі. Ата-анамен бөлісу үшін қосыңыз.';

  @override
  String get openLocationSettings => 'Геолокация параметрлерін ашу';

  @override
  String get locationBlocked => 'Геолокация рұқсаты бұғатталған';

  @override
  String get enableLocationAccess =>
      'Жүйе параметрлерінде геолокацияға рұқсат беріңіз.';

  @override
  String get openAppSettings => 'Қолданба параметрлерін ашу';

  @override
  String get allowLocationToShare => 'Бөлісу үшін геолокацияға рұқсат беріңіз';

  @override
  String get grantLocationPermission =>
      'Ата-анаңыз сіздің қайда екеніңізді білу үшін рұқсат беріңіз.';

  @override
  String get allowLocation => 'Геолокацияға рұқсат беру';

  @override
  String get myChildren => 'Менің балаларым';

  @override
  String get addChild => 'Бала қосу';

  @override
  String get noChildrenYet =>
      'Балалар жоқ. Профиль жасау үшін «Бала қосу» түймесін басыңыз.';

  @override
  String get parentAccount => 'Ата-ана аккаунты';

  @override
  String get changePhoto => 'Суретті өзгерту';

  @override
  String get deleteChildTitle => 'Баланы жою?';

  @override
  String deleteChildMessage(String childName) {
    return '$childName және байланысты барлық белсенділік тарихын жою керек пе?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName жойылды';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Баланы жою сәтсіз болды: $error';
  }

  @override
  String get avatarUpdated => 'Аватар жаңартылды';

  @override
  String failedGeneric(String error) {
    return 'Қате: $error';
  }

  @override
  String get createChildAccount => 'Бала аккаунтын жасау';

  @override
  String get childSignInHint =>
      'Балаңыз осы деректермен өз құрылғысында кіреді.';

  @override
  String get displayNameHint => 'Көрсетілетін атау (мысалы, Алекс)';

  @override
  String get create => 'Жасау';

  @override
  String get editChildProfile => 'Бала профилін өңдеу';

  @override
  String get save => 'Сақтау';

  @override
  String get deleteChild => 'Баланы жою';

  @override
  String get track => 'Қадағалау';

  @override
  String get edit => 'Өңдеу';

  @override
  String get settings => 'Параметрлер';

  @override
  String get parent => 'АТА-АНА';

  @override
  String get child => 'БАЛА';

  @override
  String get editProfileDetails => 'Профиль мәліметтерін өңдеу';

  @override
  String get account => 'Аккаунт';

  @override
  String get manageChildrenMenu => 'Балаларды басқару';

  @override
  String get editProfile => 'Профильді өңдеу';

  @override
  String get notifications => 'Хабарландырулар';

  @override
  String get pushNotifications => 'Push-хабарландырулар';

  @override
  String get locationAlerts => 'Орын туралы ескертулер';

  @override
  String get batteryAlerts => 'Батарея туралы ескертулер';

  @override
  String get safeZoneAlerts => 'Орын хабарламалары';

  @override
  String get notificationPermissionRequired =>
      'Ескертулер жіберу үшін рұқсат қажет';

  @override
  String get general => 'Жалпы';

  @override
  String get language => 'Тіл';

  @override
  String get systemDefault => 'Жүйе әдепкісі';

  @override
  String get helpAndSupport => 'Анықтама және қолдау';

  @override
  String get about => 'Қолданба туралы';

  @override
  String get privacyPolicy => 'Құпиялылық саясаты';

  @override
  String get signOut => 'Шығу';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Профильді өңдеу';

  @override
  String get updateProfileHint =>
      'Көрсетілетін атауды және пайдаланушы атын жаңартыңыз.';

  @override
  String get saveChanges => 'Өзгерістерді сақтау';

  @override
  String get usernameCannotBeEmpty => 'Пайдаланушы аты бос болмауы тиіс';

  @override
  String get profileUpdated => 'Профиль жаңартылды';

  @override
  String failedToUploadAvatar(String error) {
    return 'Аватарды жүктеу сәтсіз болды: $error';
  }

  @override
  String get parentProfile => 'Ата-ана профилі';

  @override
  String get addChildForStats =>
      'Тікелей статистиканы көру үшін алдымен бала аккаунтын қосыңыз.';

  @override
  String get insights => 'ТАЛДАУ';

  @override
  String childStats(String childName) {
    return '$childName статистикасы';
  }

  @override
  String get deviceStatus => 'Құрылғы күйі';

  @override
  String batteryPercent(int battery) {
    return 'Батарея $battery%';
  }

  @override
  String get batteryUnknown => 'Батарея белгісіз';

  @override
  String synced(String time) {
    return '$time синхрондалды';
  }

  @override
  String get noDeviceSyncYet => 'Синхрондау жоқ';

  @override
  String get usageAccessGranted => 'Пайдалану статистикасына рұқсат берілді';

  @override
  String get usageAccessNeeded => 'Пайдалану статистикасына рұқсат қажет';

  @override
  String get iosUsageAccessNote =>
      'Бала құрылғысы — iPhone. iOS Android-тегідей пайдалану статистикасына қол жеткізуді қамтамасыз етпейді, сондықтан қолданба бұл рұқсат экранын ашалмайды. iPhone-да нақты экран уақыты мен қолданба блоктау Apple Screen Time құқықтары мен жеке нативті интеграцияны қажет етеді.';

  @override
  String get androidUsageAccessNote =>
      'Телефондағы бала қолданбасын ашып, пайдалану статистикасына рұқсат беріңіз. Осыдан кейін экран уақыты, қолданба шектеулері және күнтізбе автоматты түрде синхрондалады.';

  @override
  String get dailyUsage => 'Күнделікті пайдалану';

  @override
  String usageOfLimit(String total, String limit) {
    return '$limit-дің $total пайдаланылды';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$date күні $total пайдаланылды';
  }

  @override
  String get allLimitsInRange => 'Барлық белсенді шектеулер қалыпты';

  @override
  String appLimitExceeded(int count) {
    return 'Бүгін $count қолданба шектеуі асып кетті';
  }

  @override
  String get setAppLimitsHint =>
      'Нақты мақсатқа айналдыру үшін төменде қолданба шектеулерін орнатыңыз.';

  @override
  String get weeklyUsage => 'Апталық пайдалану';

  @override
  String get usageCalendar => 'Пайдалану күнтізбесі';

  @override
  String get noAppUsageData => 'Бұл күн үшін қолданба пайдалану деректері жоқ.';

  @override
  String get grantUsageAccessHint =>
      'Нақты деректерді және шектеулерді басқару үшін бала телефонында пайдалану статистикасына рұқсат беріңіз.';

  @override
  String get iosAppLimitsUnavailable =>
      'Бала телефоны — iPhone. Қолданбаның ағымдағы нұсқасы Apple Screen Time интеграциясына ие емес, сондықтан iOS-та нақты қолданба пайдаланымы мен тікелей шектеулер қолжетімді емес.';

  @override
  String get enableDailyLimit => 'Күнделікті шектеуді қосу';

  @override
  String get dailyLimit => 'Күнделікті шектеу';

  @override
  String get saveLimit => 'Шектеуді сақтау';

  @override
  String get manageAppLimits => 'Қолданба шектеулерін басқару';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName $date күні пайдаланылды';
  }

  @override
  String limitMinutes(String time) {
    return 'Шектеу $time';
  }

  @override
  String get noLimit => 'Шектеусіз';

  @override
  String usageTodayOverLimit(String time) {
    return 'Бүгін $time · шектеу асып кетті';
  }

  @override
  String usageToday(String time) {
    return 'Бүгін $time';
  }

  @override
  String limitSavedFor(String appName) {
    return '$appName үшін шектеу сақталды';
  }

  @override
  String limitDisabledFor(String appName) {
    return '$appName үшін шектеу өшірілді';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Шектеуді сақтау мүмкін болмады: $error';
  }

  @override
  String get mon => 'ДС';

  @override
  String get tue => 'СС';

  @override
  String get wed => 'СР';

  @override
  String get thu => 'БС';

  @override
  String get fri => 'ЖМ';

  @override
  String get sat => 'СБ';

  @override
  String get sun => 'ЖС';

  @override
  String get over => 'АСЫП КЕТТІ';

  @override
  String get onboardingTitle => 'Қош келдіңіз!';

  @override
  String get onboardingSubtitle => 'Сіз кімсіз?';

  @override
  String get iAmParent => 'Мен ата-анамын';

  @override
  String get iAmChild => 'Мен баламын';

  @override
  String get parentSignIn => 'Кіру';

  @override
  String get parentCreateAccount => 'Тіркелгі жасау';

  @override
  String get parentAuthSubtitle => 'Отбасыңызды басқарып, қорғаңыз';

  @override
  String get childSignIn => 'Кіру';

  @override
  String get childAuthTitle => 'Сәлем!';

  @override
  String get childAuthSubtitle => 'Кіру деректерін ата-анаңыздан сұраңыз';

  @override
  String get childNavSettings => 'Параметрлер';

  @override
  String get childProfile => 'Профиль';

  @override
  String get childSettingsTitle => 'Параметрлер';

  @override
  String get childLogout => 'Шығу';

  @override
  String get inviteChild => 'Бала шақыру';

  @override
  String get inviteTitle =>
      'Балаларыңызды және отбасының басқа мүшелерін шеңберіңізге шақырыңыз';

  @override
  String get inviteSubtitle =>
      'Отбасыңыздың мүшелері қолданбаны орнатып, кодты пайдаланып шеңберге қосылулары керек';

  @override
  String get inviteCodeLabel => 'Код 3 күн жарамды';

  @override
  String get shareCode => 'Код бөлісу';

  @override
  String get getHelp => 'Көмек алу';

  @override
  String get generateCode => 'Код жасау';

  @override
  String get codeCopied => 'Код буферге көшірілді';

  @override
  String inviteShareText(String code) {
    return 'Family security-де менің отбасы шеңберіме қосылыңыз! Шақыру кодын пайдаланыңыз: $code\n\nhttps://baby-locator.online/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Код жасалмады: $error';
  }

  @override
  String get childRegisterTitle => 'Отбасына қосылу';

  @override
  String get childRegisterSubtitle =>
      'Ата-анаңыздан алған шақыру кодын енгізіңіз';

  @override
  String get inviteCode => 'Шақыру коды';

  @override
  String get next => 'Келесі';

  @override
  String get setupYourProfile => 'Профиліңізді орнатыңыз';

  @override
  String get enterYourDetails => 'Көрсетілетін атыңызды енгізіңіз';

  @override
  String get register => 'Тіркелу';

  @override
  String get invalidInviteCode => 'Жарамсыз немесе мерзімі өткен шақыру коды';

  @override
  String get alreadyHaveAccount => 'Есептік жазба бар ма? Кіру';

  @override
  String get dontHaveCode => 'Шақыру коды бар ма? Тіркелу';

  @override
  String get placesOnMap => 'Картадағы орындар';

  @override
  String get placesAndChildren => 'Орындар және балалар';

  @override
  String placesCount(int count) {
    return 'Орындар: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Бүгін белсенді: $count';
  }

  @override
  String get retry => 'Қайталау';

  @override
  String get createPlaceHint =>
      'Балаңыз келгенде немесе кеткенде хабарлама алу үшін орын жасаңыз.';

  @override
  String get untitledPlace => 'Атаусыз орын';

  @override
  String get placeDeleted => 'Орын жойылды.';

  @override
  String get editLabel => 'Өңдеу';

  @override
  String get disabledSchedule => 'Өшірілген';

  @override
  String get noDaysSelected => 'Күндер таңдалмаған';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Радиус $radius • $schedule';
  }

  @override
  String get proActive => 'Pro белсенді';

  @override
  String get freePlan => 'Тегін жоспар';

  @override
  String get manageSubscription => 'Жазылымды басқару';

  @override
  String get restorePurchases => 'Сатып алуларды қалпына келтіру';

  @override
  String get skip => 'Өткізіп жіберу';

  @override
  String get getPremium => 'Premium алу';

  @override
  String get monthly => 'Ай сайын';

  @override
  String get yearly => 'Жылдық';

  @override
  String get bestValue => 'Ең тиімді';

  @override
  String get perMonth => ' айына';

  @override
  String get perYearSave58 => 'жылына · 58% үнемдеу';

  @override
  String get paywallProductName => 'Family Security Pro';

  @override
  String get paywallUpgrade => 'Жаңарту';

  @override
  String paywallBestValueSave(int percent) {
    return 'Ең тиімді · $percent% үнемдеу';
  }

  @override
  String get paywallBenefitAddChildren =>
      'Бір отбасылық есептік жазбаға бірнеше бала қосыңыз';

  @override
  String get paywallBenefitUnlockTools =>
      'Дыбыстық мониторинг, тікелей карта, тарих, статистика және дабыл құралдарын ашыңыз';

  @override
  String get paywallBenefitFullDashboard =>
      'Тегін жоспардың шектеусіз бүкіл ата-ана тақтасын пайдаланыңыз';

  @override
  String get paywallBenefitAudio =>
      'Бала құрылғысының жанындағы тікелей қоршаған дыбыс';

  @override
  String get paywallBenefitAppLimits =>
      'Қолданба шектеулері, пайдалану аналитикасы және қозғалыс тарихы';

  @override
  String get paywallBenefitAlarm =>
      'Қатты дабыл, жетістіктер және кеңейтілген ата-ана басқаруы';

  @override
  String get paywallIncludedWithPro => 'Pro-ға кіреді';

  @override
  String get paywallPlansTitle => 'Қолжетімді жоспарлар';

  @override
  String get paywallRecommended => 'Ұсынылады';

  @override
  String paywallPerMonthEquivalent(String price) {
    return '$price ай сайынғы баламасы';
  }

  @override
  String get paywallChooseYourPlan => 'Жоспарыңызды таңдаңыз';

  @override
  String get paywallChoosePlanDescription =>
      'Отбасыңызға сәйкес ай сайынғы немесе жылдық Family Security Pro жоспарын таңдаңыз.';

  @override
  String get paywallLoadingPlans => 'Жазылым жоспарлары жүктелуде...';

  @override
  String get paywallNoOffering => 'Қазіргі уақытта ешқандай ұсыныс жоқ.';

  @override
  String get paywallPlatformOnly =>
      'Төлем қабырғалары бұл нұсқада тек iOS және Android-де қол жетімді.';

  @override
  String get subscriptionRestored => 'Сіздің жазылымыңыз қалпына келтірілді.';

  @override
  String get noSubscriptionFound =>
      'Қалпына келтіру үшін белсенді жазылым табылмады.';

  @override
  String get subscriptionNowActive => 'Family Security Pro енді белсенді.';

  @override
  String get purchaseEntitlementPending =>
      'Сатып алу аяқталды, бірақ жазылым әлі белсендірілмеген.';

  @override
  String get premiumTitleAdditionalChildren => 'Қосымша бала профильдерін ашу';

  @override
  String get premiumTitleLiveMap => 'Отбасы тікелей картасын ашу';

  @override
  String get premiumTitleMovementHistory => 'Қозғалыс тарихын ашу';

  @override
  String get premiumTitleAudioMonitoring => 'Тікелей қоршаған дыбысты ашу';

  @override
  String get premiumTitleScreenTime => 'Экран уақытын бақылауды ашу';

  @override
  String get premiumTitleAppStats => 'Қолданба қолдану аналитикасын ашу';

  @override
  String get premiumTitleAchievements => 'Жетістіктер мен сыйлықтарды ашу';

  @override
  String get premiumTitleLoudAlarm => 'Қашықтан қатты дыбыстық сигналды ашу';

  @override
  String get premiumTitleFullMenu => 'Ата-ананың толық мәзірін ашу';

  @override
  String get premiumTitleGeneric => 'Family Security Pro ашу';

  @override
  String get premiumSubtitleAdditionalChildren =>
      'Тегін есептік жазбалар тек бір баланы басқара алады. Бүкіл отбасын қосу үчін жаңартыңыз.';

  @override
  String get premiumSubtitleLiveMap =>
      'Бір картадан балалардың нақты уақыттағы орнын, күйін және қашықтан басқарулардың.';

  @override
  String get premiumSubtitleMovementHistory =>
      'Тарихи маршруттарды шолыңыз, қозғалысты ойнатыңыз және орын өзгерістерін зерттеңіз.';

  @override
  String get premiumSubtitleAudioMonitoring =>
      'Қажет болғанда баланың жанындағы қоршаған дыбыстарды тыңдаңыз.';

  @override
  String get premiumSubtitleScreenTime =>
      'Күнделікті қолданба шектеулерін орнатыңыз, қолданбаларды бұғаттаңыз және дені сау дағдыларды қалыптастырыңыз.';

  @override
  String get premiumSubtitleAppStats =>
      'Пайдалану статистикасын, үрдістерді және қолданба деңгейінің мінез-құлқын қараңыз.';

  @override
  String get premiumSubtitleAchievements =>
      'Баланыз үшін оң дағдылар қалыптастыру үшін тапсырмаларды, жұлдыздарды және сыйлықтарды пайдаланыңыз.';

  @override
  String get premiumSubtitleLoudAlarm =>
      'Бала құрылғысын жылдам табу үшін қашықтан қатты дыбыстық сигнал іске қосыңыз.';

  @override
  String get premiumSubtitleFullMenu =>
      'Кеңейтілген ата-ана мәзірі, басқарулар және бақылау құралдары Pro-ның бөлігі болып табылады.';

  @override
  String get premiumSubtitleGeneric =>
      'Кеңейтілген ата-ана бақылауы мен бақылау құралдарын ашу үшін Family Security Pro-ға жаңартыңыз.';

  @override
  String get seePlans => 'Жоспарларды көру';
}
