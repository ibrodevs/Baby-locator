// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kirghiz Kyrgyz (`ky`).
class SKy extends S {
  SKy([String locale = 'ky']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Кириңиз же ата-эне аккаунтун түзүңүз';

  @override
  String get signIn => 'Кирүү';

  @override
  String get createParentAccount => 'Ата-эне аккаунтун түзүү';

  @override
  String get childrenSignInHint =>
      'Балдар ата-энеси түзгөн маалыматтар менен кирет.';

  @override
  String get createAccount => 'Аккаунт түзүү';

  @override
  String get displayName => 'Көрүнгөн ат';

  @override
  String get username => 'Колдонуучу аты';

  @override
  String get password => 'Сырсөз';

  @override
  String get navMap => 'Карта';

  @override
  String get navActivity => 'Активдүүлүк';

  @override
  String get navChat => 'Чат';

  @override
  String get navStats => 'Статистика';

  @override
  String get navHome => 'Башкы бет';

  @override
  String get waitingForLocation => 'Балдардын жайгашкан жери күтүлүүдө...';

  @override
  String get addChildToTrack => 'Байкоону баштоо үчүн бала кошуңуз';

  @override
  String get manageChildren => 'Балдарды башкаруу';

  @override
  String get loud => 'КАТУУ';

  @override
  String get around => 'АЙЛАНАСЫ';

  @override
  String get currentLocation => 'УЧУРДАГЫ ЖАЙГАШУУ';

  @override
  String messageChild(String childName) {
    return '$childName-га билдирүү жөнөтүү';
  }

  @override
  String get history => 'Тарых';

  @override
  String lastUpdated(String time) {
    return 'Жаңыртылды: $time';
  }

  @override
  String get statusActive => 'АКТИВДҮҮ';

  @override
  String get statusPaused => 'ТОКТОТУЛДУ';

  @override
  String get statusOffline => 'ОФЛАЙН';

  @override
  String get justNow => 'Азыр эле';

  @override
  String minutesAgo(int minutes) {
    return '$minutes мүн. мурун';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours саат мурун';
  }

  @override
  String get active => 'Активдүү';

  @override
  String get inactive => 'Активдүү эмес';

  @override
  String get addChildToSeeActivity => 'Активдүүлүктү көрүү үчүн бала кошуңуз';

  @override
  String get activity => 'Активдүүлүк';

  @override
  String get today => 'Бүгүн';

  @override
  String get leftArea => 'Аймактан чыкты';

  @override
  String get arrivedAtLocation => 'Жерге жетти';

  @override
  String get phoneCharging => 'Телефон заряддалууда';

  @override
  String batteryReached(int battery) {
    return 'Батарея заряды $battery%-га жетти';
  }

  @override
  String get batteryLow => 'Батарея заряды аз';

  @override
  String batteryDropped(int battery) {
    return 'Батарея заряды $battery%-га чейин төмөндөдү';
  }

  @override
  String get currentLocationTitle => 'Учурдагы жайгашуу';

  @override
  String get locationShared => 'Жайгашкан жер жөнөтүлдү';

  @override
  String get batteryStatus => 'Батарея абалы';

  @override
  String batteryAt(int battery) {
    return 'Батарея: $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Активдүүлүк жок. $childName жайгашкан жерин жөнөткөндөн кийин окуялар пайда болот.';
  }

  @override
  String get safeZones => 'Коопсуз аймактар';

  @override
  String get addNew => 'Жаңы кошуу';

  @override
  String get noSafeZonesYet => 'Коопсуз аймактар азырынча жок';

  @override
  String zone(String zoneName) {
    return 'Аймак: $zoneName';
  }

  @override
  String get editZone => 'Аймакты түзөтүү';

  @override
  String get activeToday => 'БҮГҮН АКТИВДҮҮ';

  @override
  String get inactiveToday => 'БҮГҮН АКТИВДҮҮ ЭМЕС';

  @override
  String get disabled => 'ӨЧҮРҮЛГӨН';

  @override
  String get dailySafetyScore => 'Күнүмдүк коопсуздук көрсөткүчү';

  @override
  String get noLocationUpdatesYet => 'Бүгүн жайгашуу жаңыртуулары жок';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return 'Бүгүн $totalUpdates жаңыртуунун $inZoneUpdates-и коопсуз аймактарда болду';
  }

  @override
  String coverage(int percent) {
    return 'Камтуу: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Учурдагы аймак: $zoneName';
  }

  @override
  String get addSafeZone => 'Коопсуз аймак кошуу';

  @override
  String get editSafeZone => 'Коопсуз аймакты түзөтүү';

  @override
  String get deleteZoneTitle => 'Аймакты жок кылуу?';

  @override
  String get deleteZoneMessage => 'Бул аракетти кайтарып болбойт.';

  @override
  String get cancel => 'Жокко чыгаруу';

  @override
  String get delete => 'Жок кылуу';

  @override
  String get zoneEnabled => 'АЙМАК АКТИВДҮҮ';

  @override
  String get zoneName => 'АЙМАКТЫН АТЫ';

  @override
  String get zoneNameHint => 'мис., Үй, Мектеп';

  @override
  String get activeWhen => 'КАЧАН АКТИВДҮҮ';

  @override
  String get always => 'Ар дайым';

  @override
  String get daysOfWeek => 'Жума күндөрү';

  @override
  String get chooseAtLeastOneDay =>
      'Бул график үчүн жок дегенде бир күн тандаңыз.';

  @override
  String get radius => 'РАДИУС';

  @override
  String get locationMoveMap =>
      'ЖАЙГАШУУ (Белгиченин ортосуна коюу үчүн картаны жылдырыңыз)';

  @override
  String get moveMapToSetCenter =>
      'Аймактын борборун орнотуу үчүн картаны жылдырыңыз';

  @override
  String get createSafeZone => 'Коопсуз аймак түзүү';

  @override
  String get updateSafeZone => 'Коопсуз аймакты жаңыртуу';

  @override
  String get pleaseEnterZoneName => 'Аймактын атын киргизиңиз';

  @override
  String get chooseAtLeastOneDayError =>
      'Жок дегенде бир активдүү күн тандаңыз';

  @override
  String get addChildToChat => 'Чатты баштоо үчүн бала кошуңуз';

  @override
  String get noMessagesYet => 'Билдирүүлөр жок. Саламдашыңыз!';

  @override
  String get sendMessage => 'Билдирүү жөнөтүү...';

  @override
  String failedToSend(String error) {
    return 'Жөнөтүлгөн жок: $error';
  }

  @override
  String helloUser(String name) {
    return 'Салам, $name!';
  }

  @override
  String get kidMode => 'Бала режими';

  @override
  String get myLocation => 'Менин жайгашуум';

  @override
  String get waitingForGps => 'GPS күтүлүүдө...';

  @override
  String sharedWithParent(String time) {
    return 'Ата-энеге жөнөтүлдү · $time';
  }

  @override
  String get notSharedYet => 'Азырынча жөнөтүлгөн жок';

  @override
  String get imSafe => 'Мен коопсуз жерде';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Ата-энеңе «Мен коопсуз жерде» билдирүүсү жөнөтүлдү';

  @override
  String get sosMessage => 'SOS! Мага жардам керек!';

  @override
  String sosLocation(String address) {
    return ' Жайгашуу: $address';
  }

  @override
  String get sosSent => 'SOS жөнөтүлдү — ата-эне кабарландырылат';

  @override
  String get allowUsageAccess => 'Колдонуу статистикасына уруксат берүү';

  @override
  String get usageAccessDescription =>
      'Бул ата-эне башкаруу тактасына бул телефондогу экран убактысынын чыныгы маалыматтарын жана колдонмо чектөөлөрүн көрсөтүүгө мүмкүндүк берет.';

  @override
  String get openUsageAccess => 'Колдонуу статистикасын ачуу';

  @override
  String syncError(String error) {
    return 'Синхрондоо катасы: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone чектөөсү';

  @override
  String get iphoneUsageDescription =>
      'iPhone-до Android сыяктуу колдонуу статистикасы экраны жок. Колдонмо боюнча чыныгы экран убактысы жана түз бөгөттөө Apple Screen Time API жана атайын укуктарды талап кылат, андыктан бул баскыч iOS-то иштебейт.';

  @override
  String get turnOnLocation => 'Геолокация кызматтарын иштетүү';

  @override
  String get locationIsOff =>
      'Геолокация өчүрүлгөн. Ата-эне менен бөлүшүү үчүн иштетиңиз.';

  @override
  String get openLocationSettings => 'Геолокация жөндөөлөрүн ачуу';

  @override
  String get locationBlocked => 'Геолокация уруксаты бөгөттөлгөн';

  @override
  String get enableLocationAccess =>
      'Тутум жөндөөлөрүндө геолокацияга уруксат бериңиз.';

  @override
  String get openAppSettings => 'Колдонмо жөндөөлөрүн ачуу';

  @override
  String get allowLocationToShare =>
      'Бөлүшүү үчүн геолокацияга уруксат бериңиз';

  @override
  String get grantLocationPermission =>
      'Ата-энеңиз кайда экениңизди билиши үчүн уруксат бериңиз.';

  @override
  String get allowLocation => 'Геолокацияга уруксат берүү';

  @override
  String get myChildren => 'Менин балдарым';

  @override
  String get addChild => 'Бала кошуу';

  @override
  String get noChildrenYet =>
      'Балдар жок. Профиль түзүү үчүн «Бала кошуу» баскычын басыңыз.';

  @override
  String get parentAccount => 'Ата-эне аккаунту';

  @override
  String get changePhoto => 'Сүрөттү өзгөртүү';

  @override
  String get deleteChildTitle => 'Баланы жок кылуу?';

  @override
  String deleteChildMessage(String childName) {
    return '$childName жана байланышкан бардык активдүүлүк тарыхын жок кылуу керекпи?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName жок кылынды';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Баланы жок кылуу ийгиликсиз болду: $error';
  }

  @override
  String get avatarUpdated => 'Аватар жаңыртылды';

  @override
  String failedGeneric(String error) {
    return 'Ката: $error';
  }

  @override
  String get createChildAccount => 'Бала аккаунтун түзүү';

  @override
  String get childSignInHint =>
      'Балаңыз бул маалыматтар менен өз түзмөгүндө кирет.';

  @override
  String get displayNameHint => 'Көрүнгөн ат (мис., Алекс)';

  @override
  String get create => 'Түзүү';

  @override
  String get editChildProfile => 'Бала профилин түзөтүү';

  @override
  String get save => 'Сактоо';

  @override
  String get deleteChild => 'Баланы жок кылуу';

  @override
  String get track => 'Байкоо';

  @override
  String get edit => 'Түзөтүү';

  @override
  String get settings => 'Жөндөөлөр';

  @override
  String get parent => 'АТА-ЭНЕ';

  @override
  String get child => 'БАЛА';

  @override
  String get editProfileDetails => 'Профиль маалыматтарын түзөтүү';

  @override
  String get account => 'Аккаунт';

  @override
  String get manageChildrenMenu => 'Балдарды башкаруу';

  @override
  String get editProfile => 'Профилди түзөтүү';

  @override
  String get notifications => 'Билдирмелер';

  @override
  String get pushNotifications => 'Push-билдирмелер';

  @override
  String get locationAlerts => 'Жайгашуу эскертүүлөрү';

  @override
  String get batteryAlerts => 'Батарея эскертүүлөрү';

  @override
  String get safeZoneAlerts => 'Коопсуз аймак эскертүүлөрү';

  @override
  String get notificationPermissionRequired =>
      'Эскертүү жөнөтүү үчүн уруксат талап кылынат';

  @override
  String get general => 'Жалпы';

  @override
  String get language => 'Тил';

  @override
  String get systemDefault => 'Тутум демейкиси';

  @override
  String get helpAndSupport => 'Жардам жана колдоо';

  @override
  String get about => 'Колдонмо жөнүндө';

  @override
  String get privacyPolicy => 'Купуялык саясаты';

  @override
  String get signOut => 'Чыгуу';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Профилди түзөтүү';

  @override
  String get updateProfileHint =>
      'Көрүнгөн атты жана колдонуучу атын жаңыртыңыз.';

  @override
  String get saveChanges => 'Өзгөртүүлөрдү сактоо';

  @override
  String get usernameCannotBeEmpty => 'Колдонуучу аты бош болбошу керек';

  @override
  String get profileUpdated => 'Профиль жаңыртылды';

  @override
  String failedToUploadAvatar(String error) {
    return 'Аватарды жүктөп берүү ийгиликсиз болду: $error';
  }

  @override
  String get parentProfile => 'Ата-эне профили';

  @override
  String get addChildForStats =>
      'Тикелей статистиканы көрүү үчүн алгач бала аккаунтун кошуңуз.';

  @override
  String get insights => 'ТАЛДОО';

  @override
  String childStats(String childName) {
    return '$childNameнын статистикасы';
  }

  @override
  String get deviceStatus => 'Түзмөктүн абалы';

  @override
  String batteryPercent(int battery) {
    return 'Батарея $battery%';
  }

  @override
  String get batteryUnknown => 'Батарея белгисиз';

  @override
  String synced(String time) {
    return '$time синхрондолду';
  }

  @override
  String get noDeviceSyncYet => 'Синхрондоо жок';

  @override
  String get usageAccessGranted => 'Колдонуу статистикасына уруксат берилди';

  @override
  String get usageAccessNeeded => 'Колдонуу статистикасына уруксат керек';

  @override
  String get iosUsageAccessNote =>
      'Баланын түзмөгү — iPhone. iOS Android сыяктуу колдонуу статистикасына кирүүнү камсыздабайт, андыктан колдонмо бул уруксат экранын ача албайт. iPhone-до чыныгы экран убактысы жана колдонмо бөгөттөө Apple Screen Time укуктарын жана өзүнчө нативдик интеграцияны талап кылат.';

  @override
  String get androidUsageAccessNote =>
      'Телефондогу бала колдонмосун ачып, колдонуу статистикасына уруксат бериңиз. Андан кийин экран убактысы, колдонмо чектөөлөрү жана күнтизме автоматтык түрдө синхрондолот.';

  @override
  String get dailyUsage => 'Күнүмдүк колдонуу';

  @override
  String usageOfLimit(String total, String limit) {
    return '$limitдун $total колдонулду';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$date күнү $total колдонулду';
  }

  @override
  String get allLimitsInRange => 'Бардык активдүү чектөөлөр нормада';

  @override
  String appLimitExceeded(int count) {
    return 'Бүгүн $count колдонмо чектөөсү ашып кетти';
  }

  @override
  String get setAppLimitsHint =>
      'Чыныгы максатка айландыруу үчүн төмөндө колдонмо чектөөлөрүн орнотуңуз.';

  @override
  String get weeklyUsage => 'Жумалык колдонуу';

  @override
  String get usageCalendar => 'Колдонуу күнтизмеси';

  @override
  String get noAppUsageData =>
      'Бул күн үчүн колдонмо колдонуу маалыматтары жок.';

  @override
  String get grantUsageAccessHint =>
      'Чыныгы маалыматтарды жана чектөөлөрдү башкаруу үчүн баланын телефонунда колдонуу статистикасына уруксат бериңиз.';

  @override
  String get iosAppLimitsUnavailable =>
      'Баланын телефону — iPhone. Колдонмонун учурдагы версиясы Apple Screen Time интеграциясына ээ эмес, андыктан iOS-то чыныгы колдонмо колдонуусу жана түз чектөөлөр жеткиликсиз.';

  @override
  String get enableDailyLimit => 'Күнүмдүк чектөөнү иштетүү';

  @override
  String get dailyLimit => 'Күнүмдүк чектөө';

  @override
  String get saveLimit => 'Чектөөнү сактоо';

  @override
  String get manageAppLimits => 'Колдонмо чектөөлөрүн башкаруу';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName $date күнү колдонулду';
  }

  @override
  String limitMinutes(String time) {
    return 'Чектөө $time';
  }

  @override
  String get noLimit => 'Чектөөсүз';

  @override
  String usageTodayOverLimit(String time) {
    return 'Бүгүн $time · чектөө ашып кетти';
  }

  @override
  String usageToday(String time) {
    return 'Бүгүн $time';
  }

  @override
  String limitSavedFor(String appName) {
    return '$appName үчүн чектөө сакталды';
  }

  @override
  String limitDisabledFor(String appName) {
    return '$appName үчүн чектөө өчүрүлдү';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Чектөөнү сактоо мүмкүн болгон жок: $error';
  }

  @override
  String get mon => 'ДШ';

  @override
  String get tue => 'СШ';

  @override
  String get wed => 'ШШ';

  @override
  String get thu => 'БШ';

  @override
  String get fri => 'ЖМ';

  @override
  String get sat => 'ИШ';

  @override
  String get sun => 'ЖК';

  @override
  String get over => 'АШЫП КЕТТИ';

  @override
  String get onboardingTitle => 'Кош келиңиз!';

  @override
  String get onboardingSubtitle => 'Сиз кимсиз?';

  @override
  String get iAmParent => 'Мен ата-энемин';

  @override
  String get iAmChild => 'Мен баламын';

  @override
  String get parentSignIn => 'Кирүү';

  @override
  String get parentCreateAccount => 'Аккаунт түзүү';

  @override
  String get parentAuthSubtitle => 'Үй-бүлөңүздү башкарып жана коргоңуз';

  @override
  String get childSignIn => 'Кирүү';

  @override
  String get childAuthTitle => 'Салам!';

  @override
  String get childAuthSubtitle => 'Кирүү маалыматыңызды ата-энеңизден сураңыз';

  @override
  String get childNavSettings => 'Жөндөөлөр';

  @override
  String get childProfile => 'Профиль';

  @override
  String get childSettingsTitle => 'Жөндөөлөр';

  @override
  String get childLogout => 'Чыгуу';

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
    return 'Join my family circle in Family security! Use invite code: $code\n\nhttp://89.108.81.151/invite/$code';
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
