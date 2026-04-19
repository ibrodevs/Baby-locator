// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class SUz extends S {
  SUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'Kid Security';

  @override
  String get signInOrCreate => 'Ota-ona akkauntiga kiring yoki yarating';

  @override
  String get signIn => 'Kirish';

  @override
  String get createParentAccount => 'Ota-ona akkauntini yaratish';

  @override
  String get childrenSignInHint =>
      'Bolalar ota-onasi yaratgan hisob ma\'lumotlari bilan kiradi.';

  @override
  String get createAccount => 'Akkaunt yaratish';

  @override
  String get displayName => 'Ko\'rinadigan ism';

  @override
  String get username => 'Foydalanuvchi nomi';

  @override
  String get password => 'Parol';

  @override
  String get navMap => 'Xarita';

  @override
  String get navActivity => 'Faollik';

  @override
  String get navChat => 'Chat';

  @override
  String get navStats => 'Statistika';

  @override
  String get navHome => 'Asosiy';

  @override
  String get waitingForLocation =>
      'Bolalar joylashuvni ulashishini kutmoqda...';

  @override
  String get addChildToTrack => 'Kuzatishni boshlash uchun bola qo\'shing';

  @override
  String get manageChildren => 'Bolalarni boshqarish';

  @override
  String get loud => 'BALAND';

  @override
  String get around => 'YAQINDA';

  @override
  String get currentLocation => 'JORIY JOYLASHUV';

  @override
  String messageChild(String childName) {
    return '$childName ga yozish';
  }

  @override
  String get history => 'Tarix';

  @override
  String lastUpdated(String time) {
    return 'Oxirgi yangilanish: $time';
  }

  @override
  String get statusActive => 'FAOL';

  @override
  String get statusPaused => 'TO\'XTATILGAN';

  @override
  String get statusOffline => 'OFFLAYN';

  @override
  String get justNow => 'Hozirgina';

  @override
  String minutesAgo(int minutes) {
    return '$minutes daq. oldin';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours soat oldin';
  }

  @override
  String get active => 'Faol';

  @override
  String get inactive => 'Nofaol';

  @override
  String get addChildToSeeActivity => 'Faollikni ko\'rish uchun bola qo\'shing';

  @override
  String get activity => 'Faollik';

  @override
  String get today => 'Bugun';

  @override
  String get leftArea => 'Hududni tark etdi';

  @override
  String get arrivedAtLocation => 'Joyga yetib keldi';

  @override
  String get phoneCharging => 'Telefon quvvatlanmoqda';

  @override
  String batteryReached(int battery) {
    return 'Batareya $battery% ga yetdi';
  }

  @override
  String get batteryLow => 'Batareya past';

  @override
  String batteryDropped(int battery) {
    return 'Batareya $battery% gacha tushdi';
  }

  @override
  String get currentLocationTitle => 'Joriy joylashuv';

  @override
  String get locationShared => 'Joylashuv ulashildi';

  @override
  String get batteryStatus => 'Batareya holati';

  @override
  String batteryAt(int battery) {
    return 'Batareya $battery% da';
  }

  @override
  String noActivityYet(String childName) {
    return 'Hozircha faollik yo\'q. $childName joylashuvini ulashgach hodisalar shu yerda ko\'rinadi.';
  }

  @override
  String get safeZones => 'Xavfsiz hududlar';

  @override
  String get addNew => 'Qo\'shish';

  @override
  String get noSafeZonesYet => 'Hozircha xavfsiz hududlar yo\'q';

  @override
  String zone(String zoneName) {
    return 'Hudud: $zoneName';
  }

  @override
  String get editZone => 'Hududni tahrirlash';

  @override
  String get activeToday => 'BUGUN FAOL';

  @override
  String get inactiveToday => 'BUGUN NOFAOL';

  @override
  String get disabled => 'O\'CHIRILGAN';

  @override
  String get dailySafetyScore => 'Kunlik xavfsizlik ko\'rsatkichi';

  @override
  String get noLocationUpdatesYet => 'Bugun joylashuv yangilanishlari yo\'q';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return 'Bugungi $totalUpdates yangilanishdan $inZoneUpdates tasi xavfsiz hududda bo\'lgan';
  }

  @override
  String coverage(int percent) {
    return 'Qamrov: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Joriy hudud: $zoneName';
  }

  @override
  String get addSafeZone => 'Xavfsiz hudud qo\'shish';

  @override
  String get editSafeZone => 'Xavfsiz hududni tahrirlash';

  @override
  String get deleteZoneTitle => 'Hudud o\'chirilsinmi?';

  @override
  String get deleteZoneMessage => 'Bu amalni bekor qilib bo\'lmaydi.';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get delete => 'O\'chirish';

  @override
  String get zoneEnabled => 'HUDUD YOQILGAN';

  @override
  String get zoneName => 'HUDUD NOMI';

  @override
  String get zoneNameHint => 'masalan, Uy, Maktab';

  @override
  String get activeWhen => 'QACHON FAOL';

  @override
  String get always => 'Har doim';

  @override
  String get daysOfWeek => 'Hafta kunlari';

  @override
  String get chooseAtLeastOneDay =>
      'Bu jadval uchun kamida bitta kunni tanlang.';

  @override
  String get radius => 'RADIUS';

  @override
  String get locationMoveMap =>
      'JOYLASHUV (Markazni belgilash uchun xaritani siljiting)';

  @override
  String get moveMapToSetCenter =>
      'Hudud markazini belgilash uchun xaritani siljiting';

  @override
  String get createSafeZone => 'Xavfsiz hudud yaratish';

  @override
  String get updateSafeZone => 'Xavfsiz hududni yangilash';

  @override
  String get pleaseEnterZoneName => 'Iltimos, hudud nomini kiriting';

  @override
  String get chooseAtLeastOneDayError => 'Kamida bitta faol kunni tanlang';

  @override
  String get addChildToChat => 'Chatni boshlash uchun bola qo\'shing';

  @override
  String get noMessagesYet => 'Hozircha xabarlar yo\'q. Salom yozing!';

  @override
  String get sendMessage => 'Xabar yozing...';

  @override
  String failedToSend(String error) {
    return 'Yuborib bo\'lmadi: $error';
  }

  @override
  String helloUser(String name) {
    return 'Salom, $name!';
  }

  @override
  String get kidMode => 'Bola rejimi';

  @override
  String get myLocation => 'Mening joylashuvim';

  @override
  String get waitingForGps => 'GPS kutilmoqda...';

  @override
  String sharedWithParent(String time) {
    return 'Ota-onaga ulashildi · $time';
  }

  @override
  String get notSharedYet => 'Hali ulashilmagan';

  @override
  String get imSafe => 'Men xavfsizman';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => '\"Men xavfsizman\" xabari ota-onangizga yuborildi';

  @override
  String get sosMessage => 'SOS! Menga yordam kerak!';

  @override
  String sosLocation(String address) {
    return ' Joylashuv: $address';
  }

  @override
  String get sosSent => 'SOS yuborildi — ota-ona xabardor qilinadi';

  @override
  String get allowUsageAccess => 'Foydalanish ruxsatini yoqing';

  @override
  String get usageAccessDescription =>
      'Bu ota-ona panelida ushbu telefondan real ekran vaqti va ilova limitlarini ko\'rsatishga imkon beradi.';

  @override
  String get openUsageAccess => 'Foydalanish ruxsatini ochish';

  @override
  String syncError(String error) {
    return 'Sinxronlash xatosi: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone cheklovi';

  @override
  String get iphoneUsageDescription =>
      'iPhone\'da Android\'dagidek foydalanish ruxsati oynasi yo\'q. Ilovalar bo\'yicha haqiqiy ekran vaqti va to\'g\'ridan-to\'g\'ri bloklash uchun Apple Screen Time API va maxsus ruxsatlar kerak, shuning uchun bu tugma iOS\'da ishlamaydi.';

  @override
  String get turnOnLocation => 'Joylashuv xizmatlarini yoqing';

  @override
  String get locationIsOff =>
      'Joylashuv o\'chirilgan. Ota-onaga ulashish uchun uni yoqing.';

  @override
  String get openLocationSettings => 'Joylashuv sozlamalarini ochish';

  @override
  String get locationBlocked => 'Joylashuv ruxsati bloklangan';

  @override
  String get enableLocationAccess =>
      'Tizim sozlamalarida joylashuv ruxsatini yoqing.';

  @override
  String get openAppSettings => 'Ilova sozlamalarini ochish';

  @override
  String get allowLocationToShare => 'Ulashish uchun joylashuvga ruxsat bering';

  @override
  String get grantLocationPermission =>
      'Ota-onangiz sizning qayerda ekaningizni ko\'rishi uchun ruxsat bering.';

  @override
  String get allowLocation => 'Joylashuvga ruxsat berish';

  @override
  String get myChildren => 'Mening bolalarim';

  @override
  String get addChild => 'Bola qo\'shish';

  @override
  String get noChildrenYet =>
      'Hozircha bolalar yo\'q. Yangi profil yaratish uchun \"Bola qo\'shish\"ni bosing.';

  @override
  String get parentAccount => 'Ota-ona akkaunti';

  @override
  String get changePhoto => 'Suratni o\'zgartirish';

  @override
  String get deleteChildTitle => 'Bola o\'chirilsinmi?';

  @override
  String deleteChildMessage(String childName) {
    return '$childName va u bilan bog\'liq barcha faollik tarixini o\'chirilsinmi?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName o\'chirildi';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Bolani o\'chirib bo\'lmadi: $error';
  }

  @override
  String get avatarUpdated => 'Avatar yangilandi';

  @override
  String failedGeneric(String error) {
    return 'Xato: $error';
  }

  @override
  String get createChildAccount => 'Bola akkauntini yaratish';

  @override
  String get childSignInHint =>
      'Farzandingiz qurilmasida shu ma\'lumotlar bilan kiradi.';

  @override
  String get displayNameHint => 'Ko\'rinadigan ism (masalan, Alex)';

  @override
  String get create => 'Yaratish';

  @override
  String get editChildProfile => 'Bola profilini tahrirlash';

  @override
  String get save => 'Saqlash';

  @override
  String get deleteChild => 'Bolani o\'chirish';

  @override
  String get track => 'Kuzatish';

  @override
  String get edit => 'Tahrirlash';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get parent => 'OTA-ONA';

  @override
  String get child => 'BOLA';

  @override
  String get editProfileDetails => 'Profil ma\'lumotlarini tahrirlash';

  @override
  String get account => 'Akkaunt';

  @override
  String get manageChildrenMenu => 'Bolalarni boshqarish';

  @override
  String get editProfile => 'Profilni tahrirlash';

  @override
  String get notifications => 'Bildirishnomalar';

  @override
  String get pushNotifications => 'Push bildirishnomalar';

  @override
  String get locationAlerts => 'Joylashuv ogohlantirishlari';

  @override
  String get batteryAlerts => 'Batareya ogohlantirishlari';

  @override
  String get safeZoneAlerts => 'Xavfsiz hudud ogohlantirishlari';

  @override
  String get notificationPermissionRequired =>
      'Ogohlantirish yuborish uchun bildirishnoma ruxsati kerak';

  @override
  String get general => 'Umumiy';

  @override
  String get language => 'Til';

  @override
  String get systemDefault => 'Tizim bo\'yicha';

  @override
  String get helpAndSupport => 'Yordam va qo\'llab-quvvatlash';

  @override
  String get about => 'Ilova haqida';

  @override
  String get privacyPolicy => 'Maxfiylik siyosati';

  @override
  String get signOut => 'Chiqish';

  @override
  String get appVersion => 'Kid Security v1.0.0';

  @override
  String get editProfileTitle => 'Profilni tahrirlash';

  @override
  String get updateProfileHint =>
      'Ko\'rinadigan ismingiz va foydalanuvchi nomingizni yangilang.';

  @override
  String get saveChanges => 'O\'zgarishlarni saqlash';

  @override
  String get usernameCannotBeEmpty =>
      'Foydalanuvchi nomi bo\'sh bo\'lishi mumkin emas';

  @override
  String get profileUpdated => 'Profil yangilandi';

  @override
  String failedToUploadAvatar(String error) {
    return 'Avatar yuklab bo\'lmadi: $error';
  }

  @override
  String get parentProfile => 'Ota-ona profili';

  @override
  String get addChildForStats =>
      'Jonli statistikani ko\'rish uchun avval bola akkauntini qo\'shing.';

  @override
  String get insights => 'TAHLIL';

  @override
  String childStats(String childName) {
    return '$childName statistikasi';
  }

  @override
  String get deviceStatus => 'Qurilma holati';

  @override
  String batteryPercent(int battery) {
    return 'Batareya $battery%';
  }

  @override
  String get batteryUnknown => 'Batareya noma\'lum';

  @override
  String synced(String time) {
    return 'Sinxronlangan $time';
  }

  @override
  String get noDeviceSyncYet => 'Qurilma hali sinxronlanmagan';

  @override
  String get usageAccessGranted => 'Foydalanish ruxsati berilgan';

  @override
  String get usageAccessNeeded => 'Foydalanish ruxsati kerak';

  @override
  String get iosUsageAccessNote =>
      'Bu bolaning qurilmasi iPhone. iOS Android\'dagi Usage Access\'ni bermaydi, shuning uchun ilova bu ruxsat oynasini ocha olmaydi. iPhone\'dagi haqiqiy ekran vaqti va ilova bloklash uchun Apple Screen Time ruxsatlari hamda alohida native integratsiya kerak.';

  @override
  String get androidUsageAccessNote =>
      'Telefonda bola ilovasini ochib, foydalanish ruxsatini bering. Shundan keyin ekran vaqti, ilova limitlari va kalendar avtomatik sinxronlanadi.';

  @override
  String get dailyUsage => 'Kunlik foydalanish';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total / $limit ishlatilgan';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$date kuni $total ishlatilgan';
  }

  @override
  String get allLimitsInRange => 'Barcha yoqilgan limitlar me\'yorida';

  @override
  String appLimitExceeded(int count) {
    return 'Bugun $count ta ilova limiti oshirildi';
  }

  @override
  String get setAppLimitsHint =>
      'Buni haqiqiy maqsadga aylantirish uchun pastda ilova limitlarini belgilang.';

  @override
  String get weeklyUsage => 'Haftalik foydalanish';

  @override
  String get usageCalendar => 'Foydalanish kalendari';

  @override
  String get noAppUsageData =>
      'Bu kun uchun hali ilova foydalanish ma\'lumoti yo\'q.';

  @override
  String get grantUsageAccessHint =>
      'Haqiqiy ilova ma\'lumotlarini ko\'rish va limitlarni boshqarish uchun bola telefonida foydalanish ruxsatini bering.';

  @override
  String get iosAppLimitsUnavailable =>
      'Bu bolaning telefoni iPhone. Joriy ilova versiyasida hali Apple Screen Time integratsiyasi yo\'q, shuning uchun iOS\'da ilovalar bo\'yicha haqiqiy foydalanish va to\'g\'ridan-to\'g\'ri limitlar mavjud emas.';

  @override
  String get enableDailyLimit => 'Kunlik limitni yoqish';

  @override
  String get dailyLimit => 'Kunlik limit';

  @override
  String get saveLimit => 'Limitni saqlash';

  @override
  String get manageAppLimits => 'Ilova limitlarini boshqarish';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$date kuni $appName ishlatilgan';
  }

  @override
  String limitMinutes(String time) {
    return 'Limit $time';
  }

  @override
  String get noLimit => 'Limitsiz';

  @override
  String usageTodayOverLimit(String time) {
    return 'Bugun $time · limitdan oshgan';
  }

  @override
  String usageToday(String time) {
    return 'Bugun $time';
  }

  @override
  String limitSavedFor(String appName) {
    return '$appName uchun limit saqlandi';
  }

  @override
  String limitDisabledFor(String appName) {
    return '$appName uchun limit o\'chirildi';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Limitni saqlab bo\'lmadi: $error';
  }

  @override
  String get mon => 'DU';

  @override
  String get tue => 'SE';

  @override
  String get wed => 'CH';

  @override
  String get thu => 'PA';

  @override
  String get fri => 'JU';

  @override
  String get sat => 'SH';

  @override
  String get sun => 'YA';

  @override
  String get over => 'OSHGAN';

  @override
  String get onboardingTitle => 'Xush kelibsiz!';

  @override
  String get onboardingSubtitle => 'Siz kimsiz?';

  @override
  String get iAmParent => 'Men ota-onaman';

  @override
  String get iAmChild => 'Men farzandman';

  @override
  String get parentSignIn => 'Kirish';

  @override
  String get parentCreateAccount => 'Hisob yaratish';

  @override
  String get parentAuthSubtitle => 'Oilangizni boshqaring va himoya qiling';

  @override
  String get childSignIn => 'Kirish';

  @override
  String get childAuthTitle => 'Salom!';

  @override
  String get childAuthSubtitle =>
      'Kirish ma\'lumotlarini ota-onangizdan so\'rang';

  @override
  String get childNavSettings => 'Sozlamalar';

  @override
  String get childProfile => 'Profil';

  @override
  String get childSettingsTitle => 'Sozlamalar';

  @override
  String get childLogout => 'Chiqish';
}
