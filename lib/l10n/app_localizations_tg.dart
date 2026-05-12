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
  String get safeZones => 'Ҷойҳо';

  @override
  String get addNew => 'Илова кардан';

  @override
  String get noSafeZonesYet => 'Ҳоло ҷойҳо нестанд';

  @override
  String zone(String zoneName) {
    return 'Ҷой: $zoneName';
  }

  @override
  String get editZone => 'Таҳрири ҷой';

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
    return 'Ҷойи ҷорӣ: $zoneName';
  }

  @override
  String get addSafeZone => 'Илова кардани ҷойи нав';

  @override
  String get editSafeZone => 'Таҳрири ҷой';

  @override
  String get deleteZoneTitle => 'Ҷой тоза шавад?';

  @override
  String get deleteZoneMessage => 'Ин амалро бозгардонидан мумкин нест.';

  @override
  String get cancel => 'Бекор кардан';

  @override
  String get delete => 'Нест кардан';

  @override
  String get zoneEnabled => 'ҶОЙ ФАЪОЛ АСТ';

  @override
  String get zoneName => 'НОМИ ҶОЙ';

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
      'ҶОЙГИРШАВӢ (Барои гузоштани нуқтаи марказӣ харитаро ҳаракат диҳед)';

  @override
  String get moveMapToSetCenter =>
      'Барои гузоштани маркази ҷой харитаро ҳаракат диҳед';

  @override
  String get createSafeZone => 'Сохтани ҷой';

  @override
  String get updateSafeZone => 'Навсозии ҷой';

  @override
  String get pleaseEnterZoneName => 'Лутфан номи ҷойро ворид кунед';

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
  String get safeZoneAlerts => 'Огоҳиномаҳои ҷой';

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
  String get inviteChild => 'Даъвати кӯдак';

  @override
  String get inviteTitle =>
      'Кӯдакон ва дигар аъзоёни оиларо ба доираи худ даъват кунед';

  @override
  String get inviteSubtitle =>
      'Аъзоёни оилаи шумо бояд барномаро насб кунанд ва бо истифода аз рамз ба доира ҳамроҳ шаванд';

  @override
  String get inviteCodeLabel => 'Рамз барои 3 рӯз эътибор дорад';

  @override
  String get shareCode => 'Мубодилаи рамз';

  @override
  String get getHelp => 'Кӯмак гиред';

  @override
  String get generateCode => 'Тавлиди рамз';

  @override
  String get codeCopied => 'Рамз ба буфер нусхабардорӣ шуд';

  @override
  String inviteShareText(String code) {
    return 'Ба доираи оилаи ман дар Family security ҳамроҳ шавед! Аз рамзи даъватнома истифода баред: $code\n\nhttps://baby-locator.online/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Тавлиди рамз нашуд: $error';
  }

  @override
  String get childRegisterTitle => 'Ба оила ҳамроҳ шавед';

  @override
  String get childRegisterSubtitle =>
      'Рамзи даъватномаи волидайнатонро ворид кунед';

  @override
  String get inviteCode => 'Рамзи даъватнома';

  @override
  String get next => 'Баъдӣ';

  @override
  String get setupYourProfile => 'Профили худро танзим кунед';

  @override
  String get enterYourDetails => 'Номи намоишии худро ворид кунед';

  @override
  String get register => 'Бақайдгирӣ';

  @override
  String get invalidInviteCode =>
      'Рамзи даъватномаи нодуруст ё мӯҳлаташ гузашта';

  @override
  String get alreadyHaveAccount => 'Аллакай ҳисоб доред? Ворид шавед';

  @override
  String get dontHaveCode => 'Рамзи даъватнома доред? Бақайдгирӣ';

  @override
  String get placesOnMap => 'Ҷойҳо дар харита';

  @override
  String get placesAndChildren => 'Ҷойҳо ва кӯдакон';

  @override
  String placesCount(int count) {
    return 'Ҷойҳо: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Имрӯз фаъол: $count';
  }

  @override
  String get retry => 'Такрор';

  @override
  String get createPlaceHint =>
      'Ҷой созед, то ҳангоми омадан ё рафтани кӯдак огоҳинома гиред.';

  @override
  String get untitledPlace => 'Ҷойи беном';

  @override
  String get placeDeleted => 'Ҷой тоза шуд.';

  @override
  String get editLabel => 'Таҳрир';

  @override
  String get disabledSchedule => 'Хомӯш';

  @override
  String get noDaysSelected => 'Рӯзҳо интихоб нашудаанд';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Радиус $radius • $schedule';
  }

  @override
  String get proActive => 'Pro фаъол';

  @override
  String get freePlan => 'Нақшаи ройгон';

  @override
  String get manageSubscription => 'Идоракунии обуна';

  @override
  String get restorePurchases => 'Харидҳоро барқарор кунед';

  @override
  String get skip => 'Гузаштан';

  @override
  String get getPremium => 'Premium гирифтан';

  @override
  String get monthly => 'Моҳона';

  @override
  String get yearly => 'Солона';

  @override
  String get bestValue => 'Беҳтарин арзиш';

  @override
  String get perMonth => 'дар як моҳ';

  @override
  String get perYearSave58 => 'дар як сол · 58% сарфа';

  @override
  String get paywallProductName => 'Family Security Pro';

  @override
  String get paywallUpgrade => 'Навсозӣ';

  @override
  String paywallBestValueSave(int percent) {
    return 'Беҳтарин арзиш · $percent% сарфа';
  }

  @override
  String get paywallBenefitAddChildren =>
      'Якчанд кӯдакро ба як ҳисоби оилавӣ илова кунед';

  @override
  String get paywallBenefitUnlockTools =>
      'Мониторинги аудио, харитаи зинда, таърих, омор ва абзорҳои огоҳиро кушоед';

  @override
  String get paywallBenefitFullDashboard =>
      'Тамоми панели волидайнро бидуни маҳдудиятҳои нақшаи ройгон нигоҳ доред';

  @override
  String get paywallBenefitAudio =>
      'Садои иҳотаи зинда дар наздикии дастгоҳи кӯдак';

  @override
  String get paywallBenefitAppLimits =>
      'Маҳдудиятҳои замима, аналитикаи истифода ва таърихи ҳаракат';

  @override
  String get paywallBenefitAlarm =>
      'Огоҳии баланд, дастовардҳо ва назорати пешрафтаи волидайн';

  @override
  String get paywallIncludedWithPro => 'Дар Pro дохил аст';

  @override
  String get paywallPlansTitle => 'Нақшаҳои дастрас';

  @override
  String get paywallRecommended => 'Тавсия карда мешавад';

  @override
  String paywallPerMonthEquivalent(String price) {
    return '$price арзиши моҳона';
  }

  @override
  String get paywallChooseYourPlan => 'Нақшаатонро интихоб кунед';

  @override
  String get paywallChoosePlanDescription =>
      'Нақшаи моҳона ё солонаи Family Security Pro-ро интихоб кунед, ки барои оилаи шумо мувофиқтарин аст.';

  @override
  String get paywallLoadingPlans => 'Нақшаҳои обуна бор мешаванд...';

  @override
  String get paywallNoOffering => 'Дар айни замон пешниҳоде вуҷуд надорад.';

  @override
  String get paywallPlatformOnly =>
      'Деворҳои пардохт танҳо дар iOS ва Android дар ин нусха дастрасанд.';

  @override
  String get subscriptionRestored => 'Обунаи шумо барқарор карда шуд.';

  @override
  String get noSubscriptionFound =>
      'Барои барқарор кардан ягон обунаи фаъол ёфт нашуд.';

  @override
  String get subscriptionNowActive => 'Family Security Pro ҳоло фаъол аст.';

  @override
  String get purchaseEntitlementPending =>
      'Харид ба итмом расид, аммо обуна ҳанӯз фаъол нест.';

  @override
  String get premiumTitleAdditionalChildren =>
      'Кушодани профилҳои бештари кӯдакон';

  @override
  String get premiumTitleLiveMap => 'Кушодани харитаи оилаи зинда';

  @override
  String get premiumTitleMovementHistory => 'Кушодани таърихи ҳаракат';

  @override
  String get premiumTitleAudioMonitoring => 'Кушодани садои иҳотаи зинда';

  @override
  String get premiumTitleScreenTime => 'Кушодани назорати вақти экран';

  @override
  String get premiumTitleAppStats => 'Кушодани аналитикаи истифодаи замима';

  @override
  String get premiumTitleAchievements => 'Кушодани дастовардҳо ва мукофотҳо';

  @override
  String get premiumTitleLoudAlarm => 'Кушодани огоҳии баланди дурдаст';

  @override
  String get premiumTitleFullMenu => 'Кушодани менюи пурраи волидайн';

  @override
  String get premiumTitleGeneric => 'Кушодани Family Security Pro';

  @override
  String get premiumSubtitleAdditionalChildren =>
      'Ҳисобҳои ройгон танҳо як кӯдакро идора мекунанд. Барои илова кардани тамоми оила навсозӣ кунед.';

  @override
  String get premiumSubtitleLiveMap =>
      'Аз як харита ҷойгиршавии кӯдакон, ҳолат ва амалиётҳои дурдастро бинед.';

  @override
  String get premiumSubtitleMovementHistory =>
      'Масирҳои таърихиро баррасӣ кунед, ҳаракатро бозпахш кунед ва тағйиротҳои ҷойгиршавиро тафтиш кунед.';

  @override
  String get premiumSubtitleAudioMonitoring =>
      'Вақте ки контексти фаврӣ лозим аст, садоҳои атрофи кӯдакро гӯш кунед.';

  @override
  String get premiumSubtitleScreenTime =>
      'Маҳдудиятҳои рӯзонаи замима танзим кунед, замимаҳоро банд кунед ва одатҳои солимтари дастгоҳро татбиқ намоед.';

  @override
  String get premiumSubtitleAppStats =>
      'Омори истифода, тамоилҳо ва таҳлили рафтори замимаро бинед.';

  @override
  String get premiumSubtitleAchievements =>
      'Барои ташаккули одатҳои мусбат барои кӯдакатон аз вазифаҳо, ситораҳо ва мукофотҳо истифода баред.';

  @override
  String get premiumSubtitleLoudAlarm =>
      'Барои ёфтани дастгоҳи кӯдак зуд, огоҳии баландро аз дур фаъол созед.';

  @override
  String get premiumSubtitleFullMenu =>
      'Менюи пешрафтаи волидайн, назоратҳо ва абзорҳои мониторинг қисми Pro мебошанд.';

  @override
  String get premiumSubtitleGeneric =>
      'Барои кушодани абзорҳои пешрафтаи назорати волидайн ба Family Security Pro навсозӣ кунед.';

  @override
  String get seePlans => 'Дидани нақшаҳо';
}
