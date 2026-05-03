// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class SKk extends S {
  SKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'Kid Security';

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
  String get safeZones => 'Қауіпсіз аймақтар';

  @override
  String get addNew => 'Жаңа қосу';

  @override
  String get noSafeZonesYet => 'Қауіпсіз аймақтар әлі жоқ';

  @override
  String zone(String zoneName) {
    return 'Аймақ: $zoneName';
  }

  @override
  String get editZone => 'Аймақты өңдеу';

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
    return 'Ағымдағы аймақ: $zoneName';
  }

  @override
  String get addSafeZone => 'Қауіпсіз аймақ қосу';

  @override
  String get editSafeZone => 'Қауіпсіз аймақты өңдеу';

  @override
  String get deleteZoneTitle => 'Аймақты жою?';

  @override
  String get deleteZoneMessage => 'Бұл әрекетті болдырмауға болмайды.';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get delete => 'Жою';

  @override
  String get zoneEnabled => 'АЙМАҚ БЕЛСЕНДІ';

  @override
  String get zoneName => 'АЙМАҚ АТАУЫ';

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
      'ОРЫН (Белгішені ортасына қою үшін картаны жылжытыңыз)';

  @override
  String get moveMapToSetCenter =>
      'Аймақ орталығын орнату үшін картаны жылжытыңыз';

  @override
  String get createSafeZone => 'Қауіпсіз аймақ жасау';

  @override
  String get updateSafeZone => 'Қауіпсіз аймақты жаңарту';

  @override
  String get pleaseEnterZoneName => 'Аймақ атауын енгізіңіз';

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
  String get safeZoneAlerts => 'Қауіпсіз аймақ ескертулері';

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
  String get appVersion => 'Kid Security v1.0.0';

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
  String get inviteChild => 'Invite Child';

  @override
  String get inviteTitle =>
      'Invite children and other family members to your circle';

  @override
  String get inviteSubtitle =>
      'Your family members need to install the app and join the circle using the code';

  @override
  String get inviteCodeLabel => 'Code valid for 3 days';

  @override
  String get shareCode => 'Share code';

  @override
  String get getHelp => 'Get help';

  @override
  String get generateCode => 'Generate Code';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String inviteShareText(String code) {
    return 'Join my family circle in Kid Security! Use invite code: $code\n\nhttp://89.108.81.151/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Failed to generate code: $error';
  }

  @override
  String get childRegisterTitle => 'Join Family';

  @override
  String get childRegisterSubtitle => 'Enter the invite code from your parent';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get next => 'Next';

  @override
  String get setupYourProfile => 'Set up your profile';

  @override
  String get enterYourDetails => 'Enter your display name';

  @override
  String get register => 'Register';

  @override
  String get invalidInviteCode => 'Invalid or expired invite code';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get dontHaveCode => 'Have an invite code? Register';
}
