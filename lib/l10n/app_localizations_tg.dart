// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tajik (`tg`).
class STg extends S {
  STg([String locale = 'tg']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Ворид шавед ё ҳисоби волидайн созед';

  @override
  String get signIn => 'Ворид шудан';

  @override
  String get createParentAccount => 'Ҳисоби волидайн созед';

  @override
  String get childrenSignInHint =>
      'Кӯдакон бо маълумоте, ки волидайнашон сохтааст, ворид мешаванд.';

  @override
  String get createAccount => 'Ҳисоб созед';

  @override
  String get displayName => 'Номи намоишӣ';

  @override
  String get username => 'Номи корбар';

  @override
  String get password => 'Рамз';

  @override
  String get navMap => 'Харита';

  @override
  String get navActivity => 'Фаъолият';

  @override
  String get navChat => 'Гуфтугӯ';

  @override
  String get navStats => 'Омор';

  @override
  String get navHome => 'Хона';

  @override
  String get waitingForLocation =>
      'Дар интизори мубодилаи мавқеъ аз ҷониби кӯдакон...';

  @override
  String get addChildToTrack => 'Кӯдакро илова кунед то пайгирӣ оғоз шавад';

  @override
  String get manageChildren => 'Идоракунии кӯдакон';

  @override
  String get loud => 'БАЛАНД';

  @override
  String get around => 'АТРОФ';

  @override
  String get currentLocation => 'МАВҚЕИ ҲОЗИРА';

  @override
  String messageChild(String childName) {
    return 'Паём ба $childName';
  }

  @override
  String get history => 'Таърих';

  @override
  String lastUpdated(String time) {
    return 'Охирин навсозӣ: $time';
  }

  @override
  String get statusActive => 'ФАЪОЛ';

  @override
  String get statusPaused => 'МАВҚУФ';

  @override
  String get statusOffline => 'ОФЛАЙН';

  @override
  String get justNow => 'Ҳозир';

  @override
  String minutesAgo(int minutes) {
    return '$minutes дақ. пеш';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours соат пеш';
  }

  @override
  String get active => 'Фаъол';

  @override
  String get inactive => 'Ғайрифаъол';

  @override
  String get addChildToSeeActivity =>
      'Кӯдакро илова кунед то фаъолиятро бубинед';

  @override
  String get activity => 'Фаъолият';

  @override
  String get today => 'Имрӯз';

  @override
  String get leftArea => 'Минтақаро тарк кард';

  @override
  String get arrivedAtLocation => 'Ба мавқеъ расид';

  @override
  String get phoneCharging => 'Телефон шарж мешавад';

  @override
  String batteryReached(int battery) {
    return 'Батарея ба $battery% расид';
  }

  @override
  String get batteryLow => 'Батарея кам аст';

  @override
  String batteryDropped(int battery) {
    return 'Батарея то $battery% афтод';
  }

  @override
  String get currentLocationTitle => 'Мавқеи ҳозира';

  @override
  String get locationShared => 'Мавқеъ мубодила шуд';

  @override
  String get batteryStatus => 'Ҳолати батарея';

  @override
  String batteryAt(int battery) {
    return 'Батарея дар $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Ҳоло фаъолияте нест. Ҳодисаҳо пас аз он, ки $childName мавқеашро мубодила кунад, намоён мешаванд.';
  }

  @override
  String get safeZones => 'Минтақаҳои бехатар';

  @override
  String get addNew => 'Илова кардан';

  @override
  String get noSafeZonesYet => 'Ҳоло минтақаи бехатаре нест';

  @override
  String zone(String zoneName) {
    return 'Минтақа: $zoneName';
  }

  @override
  String get editZone => 'Таҳрири минтақа';

  @override
  String get activeToday => 'ИМРӮЗ ФАЪОЛ';

  @override
  String get inactiveToday => 'ИМРӮЗ ҒАЙРИФАЪОЛ';

  @override
  String get disabled => 'ХОМӮШ';

  @override
  String get dailySafetyScore => 'Нишондиҳандаи бехатарии рӯзона';

  @override
  String get noLocationUpdatesYet => 'Имрӯз навсозии мавқеъ вуҷуд надорад';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates аз $totalUpdates навсозӣ имрӯз дар минтақаҳои бехатар буданд';
  }

  @override
  String coverage(int percent) {
    return 'Фарогирӣ: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Минтақаи ҳозира: $zoneName';
  }

  @override
  String get addSafeZone => 'Илова кардани минтақаи бехатар';

  @override
  String get editSafeZone => 'Таҳрири минтақаи бехатар';

  @override
  String get deleteZoneTitle => 'Минтақа нест карда шавад?';

  @override
  String get deleteZoneMessage => 'Ин амалро бозгардонидан мумкин нест.';

  @override
  String get cancel => 'Бекор кардан';

  @override
  String get delete => 'Нест кардан';

  @override
  String get zoneEnabled => 'МИНТАҚА ФАЪОЛ АСТ';

  @override
  String get zoneName => 'НОМИ МИНТАҚА';

  @override
  String get zoneNameHint => 'Масалан: Хона, Мактаб';

  @override
  String get activeWhen => 'ВАҚТИ ФАЪОЛБУДАН';

  @override
  String get always => 'Ҳамеша';

  @override
  String get daysOfWeek => 'Рӯзҳои ҳафта';

  @override
  String get chooseAtLeastOneDay =>
      'Барои ин ҷадвал ҳадди аққал як рӯзро интихоб кунед.';

  @override
  String get radius => 'РАДИУС';

  @override
  String get locationMoveMap =>
      'МАВҚЕЪ (Харитаро ба маркази нишонгузор ҳаракат диҳед)';

  @override
  String get moveMapToSetCenter =>
      'Харитаро ҳаракат диҳед то маркази минтақа муайян шавад';

  @override
  String get createSafeZone => 'Сохтани минтақаи бехатар';

  @override
  String get updateSafeZone => 'Навсозии минтақаи бехатар';

  @override
  String get pleaseEnterZoneName => 'Лутфан номи минтақаро ворид кунед';

  @override
  String get chooseAtLeastOneDayError =>
      'Ҳадди аққал як рӯзи фаъолро интихоб кунед';

  @override
  String get addChildToChat => 'Кӯдакро илова кунед то гуфтугӯ оғоз шавад';

  @override
  String get noMessagesYet => 'Ҳоло паёме нест. Салом гӯед!';

  @override
  String get sendMessage => 'Паём нависед...';

  @override
  String failedToSend(String error) {
    return 'Фиристодан нашуд: $error';
  }

  @override
  String helloUser(String name) {
    return 'Салом, $name!';
  }

  @override
  String get kidMode => 'Ҳолати кӯдак';

  @override
  String get myLocation => 'Мавқеи ман';

  @override
  String get waitingForGps => 'Дар интизори GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Бо волидайн мубодила шуд · $time';
  }

  @override
  String get notSharedYet => 'Ҳоло мубодила нашудааст';

  @override
  String get imSafe => 'Ман бехатарам';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => '\"Ман бехатарам\" ба волидайнат фиристода шуд';

  @override
  String get sosMessage => 'SOS! Ба ман кӯмак лозим аст!';

  @override
  String sosLocation(String address) {
    return ' Мавқеъ: $address';
  }

  @override
  String get sosSent => 'SOS фиристода шуд — волидайн огоҳ мешаванд';

  @override
  String get allowUsageAccess => 'Иҷозати дастрасӣ ба истифодаи барнома';

  @override
  String get usageAccessDescription =>
      'Ин ба панели волидайн имкон медиҳад маълумоти воқеии вақти экран ва маҳдудиятҳои барномаро аз ин телефон нишон диҳад.';

  @override
  String get openUsageAccess => 'Кушодани дастрасии истифода';

  @override
  String syncError(String error) {
    return 'Хатои ҳамоҳангсозӣ: $error';
  }

  @override
  String get iphoneLimitation => 'Маҳдудияти iPhone';

  @override
  String get iphoneUsageDescription =>
      'Дар iPhone экрани дастрасии истифода монанди Android вуҷуд надорад. Вақти экрани ҳар барнома ва бастани мустақими барномаҳо ба API-ҳои Screen Time Apple ва иҷозатномаҳои махсус ниёз дорад, бинобар ин ин тугма дар iOS кор намекунад.';

  @override
  String get turnOnLocation => 'Хидматҳои мавқеъро фаъол кунед';

  @override
  String get locationIsOff =>
      'Мавқеъ хомӯш аст. Онро фаъол кунед то бо волидайн мубодила шавад.';

  @override
  String get openLocationSettings => 'Кушодани танзимоти мавқеъ';

  @override
  String get locationBlocked => 'Иҷозати мавқеъ баста аст';

  @override
  String get enableLocationAccess =>
      'Дастрасии мавқеъро дар танзимоти система фаъол кунед.';

  @override
  String get openAppSettings => 'Кушодани танзимоти барнома';

  @override
  String get allowLocationToShare => 'Иҷозати мавқеъро барои мубодила диҳед';

  @override
  String get grantLocationPermission =>
      'Иҷозат диҳед то волидайнатон бидонанд шумо куҷоед.';

  @override
  String get allowLocation => 'Иҷозати мавқеъ';

  @override
  String get myChildren => 'Кӯдакони ман';

  @override
  String get addChild => 'Илова кардани кӯдак';

  @override
  String get noChildrenYet =>
      'Ҳоло кӯдаке нест. \"Илова кардани кӯдак\"-ро пахш кунед.';

  @override
  String get parentAccount => 'Ҳисоби волидайн';

  @override
  String get changePhoto => 'Иваз кардани акс';

  @override
  String get deleteChildTitle => 'Кӯдак нест карда шавад?';

  @override
  String deleteChildMessage(String childName) {
    return '$childName ва тамоми таърихи фаъолияти вобаста нест карда шавад?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName нест карда шуд';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Нест кардани кӯдак нашуд: $error';
  }

  @override
  String get avatarUpdated => 'Аватар навсозӣ шуд';

  @override
  String failedGeneric(String error) {
    return 'Хато: $error';
  }

  @override
  String get createChildAccount => 'Сохтани ҳисоби кӯдак';

  @override
  String get childSignInHint =>
      'Кӯдакатон бо ин маълумот дар дастгоҳи худ ворид мешавад.';

  @override
  String get displayNameHint => 'Номи намоишӣ (масалан: Алӣ)';

  @override
  String get create => 'Сохтан';

  @override
  String get editChildProfile => 'Таҳрири профили кӯдак';

  @override
  String get save => 'Нигоҳ доштан';

  @override
  String get deleteChild => 'Нест кардани кӯдак';

  @override
  String get track => 'Пайгирӣ';

  @override
  String get edit => 'Таҳрир';

  @override
  String get settings => 'Танзимот';

  @override
  String get parent => 'ВОЛИДАЙН';

  @override
  String get child => 'КӮДАК';

  @override
  String get editProfileDetails => 'Таҳрири тафсилоти профил';

  @override
  String get account => 'Ҳисоб';

  @override
  String get manageChildrenMenu => 'Идоракунии кӯдакон';

  @override
  String get editProfile => 'Таҳрири профил';

  @override
  String get notifications => 'Огоҳиномаҳо';

  @override
  String get pushNotifications => 'Огоҳиномаҳои push';

  @override
  String get locationAlerts => 'Огоҳиномаҳои мавқеъ';

  @override
  String get batteryAlerts => 'Огоҳиномаҳои батарея';

  @override
  String get safeZoneAlerts => 'Огоҳиномаҳои минтақаи бехатар';

  @override
  String get notificationPermissionRequired =>
      'Барои фиристодани огоҳиномаҳо иҷозат лозим аст';

  @override
  String get general => 'Умумӣ';

  @override
  String get language => 'Забон';

  @override
  String get systemDefault => 'Забони низом';

  @override
  String get helpAndSupport => 'Кӯмак ва дастгирӣ';

  @override
  String get about => 'Дар бора';

  @override
  String get privacyPolicy => 'Сиёсати махфият';

  @override
  String get signOut => 'Баромадан';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Таҳрири профил';

  @override
  String get updateProfileHint =>
      'Номи намоишӣ ва номи корбарро навсозӣ кунед.';

  @override
  String get saveChanges => 'Нигоҳ доштани тағйирот';

  @override
  String get usernameCannotBeEmpty => 'Номи корбар холӣ буда наметавонад';

  @override
  String get profileUpdated => 'Профил навсозӣ шуд';

  @override
  String failedToUploadAvatar(String error) {
    return 'Боркунии аватар нашуд: $error';
  }

  @override
  String get parentProfile => 'Профили волидайн';

  @override
  String get addChildForStats =>
      'Барои дидани омори зинда аввал ҳисоби кӯдак илова кунед.';

  @override
  String get insights => 'ТАҲЛИЛ';

  @override
  String childStats(String childName) {
    return 'Омори $childName';
  }

  @override
  String get deviceStatus => 'Ҳолати дастгоҳ';

  @override
  String batteryPercent(int battery) {
    return 'Батарея $battery%';
  }

  @override
  String get batteryUnknown => 'Батарея маълум нест';

  @override
  String synced(String time) {
    return 'Ҳамоҳанг шуд $time';
  }

  @override
  String get noDeviceSyncYet => 'Ҳоло ҳамоҳангсозии дастгоҳ нест';

  @override
  String get usageAccessGranted => 'Дастрасии истифода дода шуд';

  @override
  String get usageAccessNeeded => 'Дастрасии истифода лозим аст';

  @override
  String get iosUsageAccessNote =>
      'Дастгоҳи кӯдак iPhone аст. iOS дастрасии истифодаи монанди Android намедиҳад, бинобар ин ин барнома наметавонад он экрани иҷозатро кушояд. Вақти экрани воқеии iPhone ва бастани барнома ба иҷозатномаҳои Screen Time Apple ва ҳамгироии алоҳидаи бумӣ ниёз дорад.';

  @override
  String get androidUsageAccessNote =>
      'Барномаи кӯдакро дар телефон кушоед ва дастрасии истифодаро иҷозат диҳед. Пас аз он, вақти экран, маҳдудиятҳои барнома ва тақвим ба таври автоматӣ ҳамоҳанг мешаванд.';

  @override
  String get dailyUsage => 'Истифодаи рӯзона';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total аз $limit истифода шуд';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total дар $date истифода шуд';
  }

  @override
  String get allLimitsInRange =>
      'Тамоми маҳдудиятҳои фаъол дар доираи меъёр мебошанд';

  @override
  String appLimitExceeded(int count) {
    return 'Маҳдудияти $count барнома имрӯз аз ҳад гузашт';
  }

  @override
  String get setAppLimitsHint =>
      'Маҳдудиятҳои барномаро дар поён гузоред то ин ба ҳадафи воқеӣ табдил шавад.';

  @override
  String get weeklyUsage => 'Истифодаи ҳафтагӣ';

  @override
  String get usageCalendar => 'Тақвими истифода';

  @override
  String get noAppUsageData =>
      'Ҳоло маълумоти истифодаи барнома барои ин рӯз вуҷуд надорад.';

  @override
  String get grantUsageAccessHint =>
      'Дастрасии истифодаро дар телефони кӯдак диҳед то маълумоти воқеии барнома дида шавад ва маҳдудиятҳо идора карда шаванд.';

  @override
  String get iosAppLimitsUnavailable =>
      'Ин телефон iPhone аст. Версияи ҳозираи барнома ҳоло ҳамгироии Apple Screen Time надорад, бинобар ин истифодаи ҳар барнома ва маҳдудиятҳои мустақими барнома дар iOS дастрас нестанд.';

  @override
  String get enableDailyLimit => 'Маҳдудияти рӯзонаро фаъол кунед';

  @override
  String get dailyLimit => 'Маҳдудияти рӯзона';

  @override
  String get saveLimit => 'Нигоҳ доштани маҳдудият';

  @override
  String get manageAppLimits => 'Идоракунии маҳдудиятҳои барнома';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName дар $date истифода шуд';
  }

  @override
  String limitMinutes(String time) {
    return 'Маҳдудият $time';
  }

  @override
  String get noLimit => 'Маҳдудият нест';

  @override
  String usageTodayOverLimit(String time) {
    return '$time имрӯз · аз маҳдудият зиёд';
  }

  @override
  String usageToday(String time) {
    return '$time имрӯз';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Маҳдудият барои $appName нигоҳ дошта шуд';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Маҳдудият барои $appName хомӯш карда шуд';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Маҳдудиятро нигоҳ доштан мумкин нашуд: $error';
  }

  @override
  String get mon => 'ДШ';

  @override
  String get tue => 'СШ';

  @override
  String get wed => 'ЧШ';

  @override
  String get thu => 'ПШ';

  @override
  String get fri => 'ҶМ';

  @override
  String get sat => 'ШБ';

  @override
  String get sun => 'ЯШ';

  @override
  String get over => 'ЗИЁД';

  @override
  String get onboardingTitle => 'Хуш омадед!';

  @override
  String get onboardingSubtitle => 'Шумо кистед?';

  @override
  String get iAmParent => 'Ман волидайн ҳастам';

  @override
  String get iAmChild => 'Ман кӯдак ҳастам';

  @override
  String get parentSignIn => 'Ворид шудан';

  @override
  String get parentCreateAccount => 'Эҷоди ҳисоб';

  @override
  String get parentAuthSubtitle => 'Оилаи худро идора ва муҳофизат кунед';

  @override
  String get childSignIn => 'Ворид шудан';

  @override
  String get childAuthTitle => 'Салом!';

  @override
  String get childAuthSubtitle => 'Маълумоти воридшавиро аз волидатон пурсед';

  @override
  String get childNavSettings => 'Танзимот';

  @override
  String get childProfile => 'Профил';

  @override
  String get childSettingsTitle => 'Танзимот';

  @override
  String get childLogout => 'Баромадан';

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
