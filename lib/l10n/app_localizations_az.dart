// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class SAz extends S {
  SAz([String locale = 'az']) : super(locale);

  @override
  String get appName => 'Uşaq Təhlükəsizliyi';

  @override
  String get signInOrCreate => 'Valideyn hesabına daxil olun və ya yaradın';

  @override
  String get signIn => 'Daxil ol';

  @override
  String get createParentAccount => 'Valideyn hesabı yaradın';

  @override
  String get childrenSignInHint =>
      'Uşaqlar valideynlərinin yaratdığı məlumatlarla daxil olur.';

  @override
  String get createAccount => 'Hesab yaradın';

  @override
  String get displayName => 'Göstərilən ad';

  @override
  String get username => 'İstifadəçi adı';

  @override
  String get password => 'Şifrə';

  @override
  String get navMap => 'Xəritə';

  @override
  String get navActivity => 'Fəaliyyət';

  @override
  String get navChat => 'Söhbət';

  @override
  String get navStats => 'Statistika';

  @override
  String get navHome => 'Ana səhifə';

  @override
  String get waitingForLocation =>
      'Uşaqların yer məlumatı paylaşması gözlənilir...';

  @override
  String get addChildToTrack => 'İzləməyə başlamaq üçün uşaq əlavə edin';

  @override
  String get manageChildren => 'Uşaqları idarə et';

  @override
  String get loud => 'UCADAN';

  @override
  String get around => 'ƏTRAF';

  @override
  String get currentLocation => 'CARİ YER';

  @override
  String messageChild(String childName) {
    return '$childName-a mesaj göndər';
  }

  @override
  String get history => 'Tarixçə';

  @override
  String lastUpdated(String time) {
    return 'Son yeniləmə: $time';
  }

  @override
  String get statusActive => 'AKTİV';

  @override
  String get statusPaused => 'DAYANDIRILIB';

  @override
  String get statusOffline => 'OFFLAYNİ';

  @override
  String get justNow => 'İndicə';

  @override
  String minutesAgo(int minutes) {
    return '$minutes dəq. əvvəl';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours saat əvvəl';
  }

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Aktiv deyil';

  @override
  String get addChildToSeeActivity => 'Fəaliyyəti görmək üçün uşaq əlavə edin';

  @override
  String get activity => 'Fəaliyyət';

  @override
  String get today => 'Bu gün';

  @override
  String get leftArea => 'Ərazini tərk etdi';

  @override
  String get arrivedAtLocation => 'Yerə çatdı';

  @override
  String get phoneCharging => 'Telefon şarj olunur';

  @override
  String batteryReached(int battery) {
    return 'Batareya $battery%-ə çatdı';
  }

  @override
  String get batteryLow => 'Batareya azdır';

  @override
  String batteryDropped(int battery) {
    return 'Batareya $battery%-ə düşdü';
  }

  @override
  String get currentLocationTitle => 'Cari yer';

  @override
  String get locationShared => 'Yer paylaşıldı';

  @override
  String get batteryStatus => 'Batareya vəziyyəti';

  @override
  String batteryAt(int battery) {
    return 'Batareya $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Hələ fəaliyyət yoxdur. $childName yerini paylaşdıqdan sonra hadisələr görünəcək.';
  }

  @override
  String get safeZones => 'Məkanlar';

  @override
  String get addNew => 'Yeni əlavə et';

  @override
  String get noSafeZonesYet => 'Hələ məkan yoxdur';

  @override
  String zone(String zoneName) {
    return 'Məkan: $zoneName';
  }

  @override
  String get editZone => 'Məkanı redaktə et';

  @override
  String get activeToday => 'BU GÜN AKTİV';

  @override
  String get inactiveToday => 'BU GÜN AKTİV DEYİL';

  @override
  String get disabled => 'DEAKTIV';

  @override
  String get dailySafetyScore => 'Günlük təhlükəsizlik balı';

  @override
  String get noLocationUpdatesYet => 'Bu gün hələ yer yeniləməsi yoxdur';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return 'Bu gün $totalUpdates yeniləmədən $inZoneUpdates-i təhlükəsiz zonada idi';
  }

  @override
  String coverage(int percent) {
    return 'Əhatə: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Cari məkan: $zoneName';
  }

  @override
  String get addSafeZone => 'Yeni məkan əlavə et';

  @override
  String get editSafeZone => 'Məkanı redaktə et';

  @override
  String get deleteZoneTitle => 'Məkan silinsin?';

  @override
  String get deleteZoneMessage => 'Bu əməliyyat geri alına bilməz.';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get delete => 'Sil';

  @override
  String get zoneEnabled => 'MƏKAN AKTİVDİR';

  @override
  String get zoneName => 'MƏKANIN ADI';

  @override
  String get zoneNameHint => 'məs. Ev, Məktəb';

  @override
  String get activeWhen => 'NƏ VAXT AKTİV';

  @override
  String get always => 'Həmişə';

  @override
  String get daysOfWeek => 'Həftənin günləri';

  @override
  String get chooseAtLeastOneDay => 'Bu cədvəl üçün ən azı bir gün seçin.';

  @override
  String get radius => 'RADİUS';

  @override
  String get locationMoveMap =>
      'MƏKAN (Mərkəz nöqtəsini qoymaq üçün xəritəni hərəkət etdirin)';

  @override
  String get moveMapToSetCenter =>
      'Məkanın mərkəzini qoymaq üçün xəritəni hərəkət etdirin';

  @override
  String get createSafeZone => 'Məkan yarat';

  @override
  String get updateSafeZone => 'Məkanı yenilə';

  @override
  String get pleaseEnterZoneName => 'Zəhmət olmasa məkan adını daxil edin';

  @override
  String get chooseAtLeastOneDayError => 'Ən azı bir aktiv gün seçin';

  @override
  String get addChildToChat => 'Söhbət başlatmaq üçün uşaq əlavə edin';

  @override
  String get noMessagesYet => 'Hələ mesaj yoxdur. Salam deyin!';

  @override
  String get sendMessage => 'Mesaj göndərin...';

  @override
  String failedToSend(String error) {
    return 'Göndərilə bilmədi: $error';
  }

  @override
  String helloUser(String name) {
    return 'Salam, $name!';
  }

  @override
  String get kidMode => 'Uşaq rejimi';

  @override
  String get myLocation => 'Mənim yerim';

  @override
  String get waitingForGps => 'GPS gözlənilir...';

  @override
  String sharedWithParent(String time) {
    return 'Valideynlə paylaşıldı · $time';
  }

  @override
  String get notSharedYet => 'Hələ paylaşılmayıb';

  @override
  String get imSafe => 'Mən salamatam';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Valideyninizə \"Mən salamatam\" göndərildi';

  @override
  String get sosMessage => 'SOS! Kömək lazımdır!';

  @override
  String sosLocation(String address) {
    return ' Yer: $address';
  }

  @override
  String get sosSent => 'SOS göndərildi — valideyn xəbərdar ediləcək';

  @override
  String get allowUsageAccess => 'İstifadə hüququna icazə verin';

  @override
  String get usageAccessDescription =>
      'Bu, valideyn panelinə bu telefondan real ekran vaxtı məlumatlarını və tətbiq məhdudiyyətlərini göstərməyə imkan verir.';

  @override
  String get openUsageAccess => 'İstifadə hüququnu açın';

  @override
  String syncError(String error) {
    return 'Sinxronizasiya xətası: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone məhdudiyyəti';

  @override
  String get iphoneUsageDescription =>
      'iPhone-da Android tipli İstifadə Hüququ ekranı yoxdur. Real tətbiq ekran vaxtı və birbaşa tətbiq bloklanması Apple Screen Time API-lərini və xüsusi səlahiyyətlər tələb edir, buna görə bu düymə iOS-da işləyə bilməz.';

  @override
  String get turnOnLocation => 'Yer xidmətlərini açın';

  @override
  String get locationIsOff =>
      'Yer söndürülüb. Valideynlə paylaşmaq üçün aktiv edin.';

  @override
  String get openLocationSettings => 'Yer parametrlərini açın';

  @override
  String get locationBlocked => 'Yer icazəsi bloklanıb';

  @override
  String get enableLocationAccess =>
      'Sistem parametrlərindən yer girişini aktiv edin.';

  @override
  String get openAppSettings => 'Tətbiq parametrlərini açın';

  @override
  String get allowLocationToShare => 'Yer paylaşmağa icazə verin';

  @override
  String get grantLocationPermission =>
      'Valideynin sizi görməsi üçün icazə verin.';

  @override
  String get allowLocation => 'Yerə icazə verin';

  @override
  String get myChildren => 'Mənim uşaqlarım';

  @override
  String get addChild => 'Uşaq əlavə et';

  @override
  String get noChildrenYet =>
      'Hələ uşaq yoxdur. Yaratmaq üçün \"Uşaq əlavə et\" düyməsinə basın.';

  @override
  String get parentAccount => 'Valideyn hesabı';

  @override
  String get changePhoto => 'Şəkli dəyiş';

  @override
  String get deleteChildTitle => 'Uşaq silinsin?';

  @override
  String deleteChildMessage(String childName) {
    return '$childName və bütün əlaqəli fəaliyyət tarixçəsi silinsin?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName silindi';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Uşağı silmək alınmadı: $error';
  }

  @override
  String get avatarUpdated => 'Avatar yeniləndi';

  @override
  String failedGeneric(String error) {
    return 'Alınmadı: $error';
  }

  @override
  String get createChildAccount => 'Uşaq hesabı yaradın';

  @override
  String get childSignInHint =>
      'Uşağınız öz cihazında bu məlumatlarla daxil olacaq.';

  @override
  String get displayNameHint => 'Göstərilən ad (məs. Əli)';

  @override
  String get create => 'Yarat';

  @override
  String get editChildProfile => 'Uşaq profilini redaktə et';

  @override
  String get save => 'Saxla';

  @override
  String get deleteChild => 'Uşağı sil';

  @override
  String get track => 'İzlə';

  @override
  String get edit => 'Redaktə et';

  @override
  String get settings => 'Parametrlər';

  @override
  String get parent => 'VALİDEYN';

  @override
  String get child => 'UŞAQ';

  @override
  String get editProfileDetails => 'Profil məlumatlarını redaktə et';

  @override
  String get account => 'Hesab';

  @override
  String get manageChildrenMenu => 'Uşaqları idarə et';

  @override
  String get editProfile => 'Profili redaktə et';

  @override
  String get notifications => 'Bildirişlər';

  @override
  String get pushNotifications => 'Push bildirişlər';

  @override
  String get locationAlerts => 'Yer xəbərdarlıqları';

  @override
  String get batteryAlerts => 'Batareya xəbərdarlıqları';

  @override
  String get safeZoneAlerts => 'Məkan bildirişləri';

  @override
  String get notificationPermissionRequired =>
      'Xəbərdarlıq göndərmək üçün bildiriş icazəsi tələb olunur';

  @override
  String get general => 'Ümumi';

  @override
  String get language => 'Dil';

  @override
  String get systemDefault => 'Sistem dili';

  @override
  String get helpAndSupport => 'Yardım və dəstək';

  @override
  String get about => 'Haqqında';

  @override
  String get privacyPolicy => 'Məxfilik siyasəti';

  @override
  String get signOut => 'Çıxış';

  @override
  String get appVersion => 'Uşaq Təhlükəsizliyi v1.0.0';

  @override
  String get editProfileTitle => 'Profili redaktə et';

  @override
  String get updateProfileHint =>
      'Göstərilən adınızı və istifadəçi adınızı yeniləyin.';

  @override
  String get saveChanges => 'Dəyişiklikləri saxla';

  @override
  String get usernameCannotBeEmpty => 'İstifadəçi adı boş ola bilməz';

  @override
  String get profileUpdated => 'Profil yeniləndi';

  @override
  String failedToUploadAvatar(String error) {
    return 'Avatar yüklənə bilmədi: $error';
  }

  @override
  String get parentProfile => 'Valideyn profili';

  @override
  String get addChildForStats =>
      'Canlı statistikanı görmək üçün əvvəlcə uşaq hesabı əlavə edin.';

  @override
  String get insights => 'TƏHLILLƏR';

  @override
  String childStats(String childName) {
    return '$childName-ın Statistikası';
  }

  @override
  String get deviceStatus => 'Cihaz vəziyyəti';

  @override
  String batteryPercent(int battery) {
    return '$battery% batareya';
  }

  @override
  String get batteryUnknown => 'Batareya məlum deyil';

  @override
  String synced(String time) {
    return '$time sinxronlaşdırıldı';
  }

  @override
  String get noDeviceSyncYet => 'Hələ cihaz sinxronizasiyası yoxdur';

  @override
  String get usageAccessGranted => 'İstifadə hüququ verildi';

  @override
  String get usageAccessNeeded => 'İstifadə hüququ lazımdır';

  @override
  String get iosUsageAccessNote =>
      'Bu uşaq cihazı iPhone-dur. iOS Android İstifadə Hüququ təmin etmir, buna görə bu tətbiq həmin icazə ekranını aça bilməz. Real iPhone ekran vaxtı və tətbiq bloklanması Apple Screen Time səlahiyyətlərini və ayrıca yerli inteqrasiyanı tələb edir.';

  @override
  String get androidUsageAccessNote =>
      'Telefondan uşaq tətbiqini açın və istifadə hüququna icazə verin. Bundan sonra ekran vaxtı, tətbiq məhdudiyyətləri və təqvim avtomatik sinxronlaşacaq.';

  @override
  String get dailyUsage => 'Günlük istifadə';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total / $limit istifadə edilib';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$date tarixdə $total istifadə edilib';
  }

  @override
  String get allLimitsInRange => 'Bütün aktiv məhdudiyyətlər həddindədir';

  @override
  String appLimitExceeded(int count) {
    return 'Bu gün $count tətbiq məhdudiyyəti aşılıb';
  }

  @override
  String get setAppLimitsHint =>
      'Real hədəf yaratmaq üçün aşağıda tətbiq məhdudiyyətlərini təyin edin.';

  @override
  String get weeklyUsage => 'Həftəlik istifadə';

  @override
  String get usageCalendar => 'İstifadə təqvimi';

  @override
  String get noAppUsageData =>
      'Bu gün üçün hələ tətbiq istifadə məlumatı yoxdur.';

  @override
  String get grantUsageAccessHint =>
      'Real tətbiq məlumatlarını görmək və məhdudiyyətləri idarə etmək üçün uşaq telefonunda istifadə hüququna icazə verin.';

  @override
  String get iosAppLimitsUnavailable =>
      'Bu uşaq telefonu iPhone-dur. Cari tətbiq qurulumunda Apple Screen Time inteqrasiyası yoxdur, buna görə iOS-da real tətbiq istifadəsi və birbaşa tətbiq məhdudiyyətləri mövcud deyil.';

  @override
  String get enableDailyLimit => 'Günlük məhdudiyyəti aktiv edin';

  @override
  String get dailyLimit => 'Günlük məhdudiyyət';

  @override
  String get saveLimit => 'Məhdudiyyəti saxla';

  @override
  String get manageAppLimits => 'Tətbiq məhdudiyyətlərini idarə et';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName $date tarixdə istifadə edilib';
  }

  @override
  String limitMinutes(String time) {
    return 'Məhdudiyyət $time';
  }

  @override
  String get noLimit => 'Məhdudiyyət yoxdur';

  @override
  String usageTodayOverLimit(String time) {
    return 'Bu gün $time · hədd aşılıb';
  }

  @override
  String usageToday(String time) {
    return 'Bu gün $time';
  }

  @override
  String limitSavedFor(String appName) {
    return '$appName üçün məhdudiyyət saxlanıldı';
  }

  @override
  String limitDisabledFor(String appName) {
    return '$appName üçün məhdudiyyət deaktiv edildi';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Məhdudiyyət saxlanıla bilmədi: $error';
  }

  @override
  String get mon => 'BAZ.E';

  @override
  String get tue => 'ÇƏR.A';

  @override
  String get wed => 'ÇƏR';

  @override
  String get thu => 'CÜM.A';

  @override
  String get fri => 'CÜM';

  @override
  String get sat => 'ŞƏN';

  @override
  String get sun => 'BAZ';

  @override
  String get over => 'AŞILDI';

  @override
  String get onboardingTitle => 'Xoş gəlmisiniz!';

  @override
  String get onboardingSubtitle => 'Siz kimsiniz?';

  @override
  String get iAmParent => 'Mən valideynəm';

  @override
  String get iAmChild => 'Mən uşağam';

  @override
  String get parentSignIn => 'Daxil ol';

  @override
  String get parentCreateAccount => 'Hesab yarat';

  @override
  String get parentAuthSubtitle => 'Ailənizi idarə edin və qoruyun';

  @override
  String get childSignIn => 'Daxil ol';

  @override
  String get childAuthTitle => 'Salam!';

  @override
  String get childAuthSubtitle => 'Giriş məlumatlarını valideyninizdən alın';

  @override
  String get childNavSettings => 'Parametrlər';

  @override
  String get childProfile => 'Profil';

  @override
  String get childSettingsTitle => 'Parametrlər';

  @override
  String get childLogout => 'Çıxış';

  @override
  String get inviteChild => 'Uşaq dəvət edin';

  @override
  String get inviteTitle =>
      'Uşaqlarınızı və digər ailə üzvlərini dairənizə dəvət edin';

  @override
  String get inviteSubtitle =>
      'Ailə üzvləriniz tətbiqi quraşdırmalı və kodu istifadə edərək dairəyə qoşulmalıdır';

  @override
  String get inviteCodeLabel => 'Kod 3 gün etibarlıdır';

  @override
  String get shareCode => 'Kodu paylaşın';

  @override
  String get getHelp => 'Kömək alın';

  @override
  String get generateCode => 'Kod yaradın';

  @override
  String get codeCopied => 'Kod panoya kopyalandı';

  @override
  String inviteShareText(String code) {
    return 'Family security-də ailə dairəmə qoşulun! Dəvət kodundan istifadə edin: $code\n\nhttp://89.108.81.151/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Kod yaratmaq alınmadı: $error';
  }

  @override
  String get childRegisterTitle => 'Ailəyə qoşulun';

  @override
  String get childRegisterSubtitle => 'Valideyninizdən dəvət kodunu daxil edin';

  @override
  String get inviteCode => 'Dəvət kodu';

  @override
  String get next => 'Növbəti';

  @override
  String get setupYourProfile => 'Profilinizi qurun';

  @override
  String get enterYourDetails => 'Görünən adınızı daxil edin';

  @override
  String get register => 'Qeydiyyatdan keç';

  @override
  String get invalidInviteCode => 'Yanlış və ya müddəti keçmiş dəvət kodu';

  @override
  String get alreadyHaveAccount => 'Artıq hesabınız var? Daxil olun';

  @override
  String get dontHaveCode => 'Dəvət kodunuz var? Qeydiyyatdan keçin';

  @override
  String get placesOnMap => 'Xəritədə məkanlar';

  @override
  String get placesAndChildren => 'Məkanlar və uşaqlar';

  @override
  String placesCount(int count) {
    return 'Məkanlar: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Bu gün aktiv: $count';
  }

  @override
  String get retry => 'Təkrar et';

  @override
  String get createPlaceHint =>
      'Uşağınız gələndə və ya gedəndə bildiriş almaq üçün məkan yaradın.';

  @override
  String get untitledPlace => 'Adsız məkan';

  @override
  String get placeDeleted => 'Məkan silindi.';

  @override
  String get editLabel => 'Redaktə et';

  @override
  String get disabledSchedule => 'Söndürülüb';

  @override
  String get noDaysSelected => 'Günlər seçilməyib';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Radius $radius • $schedule';
  }

  @override
  String get proActive => 'Pro aktivdir';

  @override
  String get freePlan => 'Pulsuz plan';

  @override
  String get manageSubscription => 'Abunəliyi idarə et';

  @override
  String get restorePurchases => 'Alışları bərpa et';

  @override
  String get skip => 'Keç';

  @override
  String get getPremium => 'Premium əldə et';

  @override
  String get monthly => 'Aylıq';

  @override
  String get yearly => 'İllik';

  @override
  String get bestValue => 'Ən yaxşı dəyər';

  @override
  String get perMonth => 'aylıq';

  @override
  String get perYearSave58 => 'illik · 58% qənaət';

  @override
  String get paywallProductName => 'Family Security Pro';

  @override
  String get paywallUpgrade => 'Yüksəlt';

  @override
  String paywallBestValueSave(int percent) {
    return 'Ən yaxşı dəyər · $percent% qənaət';
  }

  @override
  String get paywallBenefitAddChildren =>
      'Bir ailə hesabına bir neçə uşaq əlavə edin';

  @override
  String get paywallBenefitUnlockTools =>
      'Audio izləmə, canlı xəritə, tarixçə, statistika və həyəcan vasitələrini açın';

  @override
  String get paywallBenefitFullDashboard =>
      'Pulsuz plan məhdudiyyəti olmadan bütün valideyn idarə panelindən istifadə edin';

  @override
  String get paywallBenefitAudio =>
      'Uşaq cihazının yaxınlığında canlı ətraf audio';

  @override
  String get paywallBenefitAppLimits =>
      'Tətbiq limitləri, istifadə analitikası və hərəkət tarixçəsi';

  @override
  String get paywallBenefitAlarm =>
      'Yüksək həyəcan siqnalı, nailiyyətlər və inkişaf etmiş valideyn nəzarəti';

  @override
  String get paywallIncludedWithPro => 'Pro-ya daxildir';

  @override
  String get paywallPlansTitle => 'Mövcud planlar';

  @override
  String get paywallRecommended => 'Tövsiyə edilir';

  @override
  String paywallPerMonthEquivalent(String price) {
    return '$price aylıq ekvivalent';
  }

  @override
  String get paywallChooseYourPlan => 'Planınızı seçin';

  @override
  String get paywallChoosePlanDescription =>
      'Ailənizdə ən uyğun aylıq və ya illik Family Security Pro planını seçin.';

  @override
  String get paywallLoadingPlans => 'Abunəlik planları yüklənir...';

  @override
  String get paywallNoOffering => 'Hazırda heç bir təklif mövcud deyil.';

  @override
  String get paywallPlatformOnly =>
      'Ödəniş divarları bu versiyada yalnız iOS və Android-də mövcuddur.';

  @override
  String get subscriptionRestored => 'Abunəliyiniz bərpa edildi.';

  @override
  String get noSubscriptionFound =>
      'Bərpa etmək üçün aktiv abunəlik tapılmadı.';

  @override
  String get subscriptionNowActive => 'Family Security Pro artıq aktivdir.';

  @override
  String get purchaseEntitlementPending =>
      'Satın alma tamamlandı, lakin abunəlik hələ aktiv deyil.';

  @override
  String get premiumTitleAdditionalChildren => 'Daha çox uşaq profili açın';

  @override
  String get premiumTitleLiveMap => 'Canlı ailə xəritəsini açın';

  @override
  String get premiumTitleMovementHistory => 'Hərəkət tarixçəsini açın';

  @override
  String get premiumTitleAudioMonitoring => 'Canlı ətraf səsi açın';

  @override
  String get premiumTitleScreenTime => 'Ekran vaxtı nəzarətini açın';

  @override
  String get premiumTitleAppStats => 'Tətbiq istifadə analitikasını açın';

  @override
  String get premiumTitleAchievements => 'Nailiyyətləri və mükafatları açın';

  @override
  String get premiumTitleLoudAlarm => 'Uzaqdan yüksək həyəcan siqnalını açın';

  @override
  String get premiumTitleFullMenu => 'Tam valideyn menyusunu açın';

  @override
  String get premiumTitleGeneric => 'Family Security Pro-nu açın';

  @override
  String get premiumSubtitleAdditionalChildren =>
      'Pulsuz hesablar yalnız bir uşağı idarə edə bilər. Bütün ailəni əlavə etmək üçün yüksəldin.';

  @override
  String get premiumSubtitleLiveMap =>
      'Bir xəritədən uşaqların real vaxt yerini, vəziyyətini və uzaqdan hərəkətlərini görün.';

  @override
  String get premiumSubtitleMovementHistory =>
      'Tarixi marşrutları nəzərdən keçirin, hərəkəti yenidən oynayın, yer dəyişikliklərini araşdırın.';

  @override
  String get premiumSubtitleAudioMonitoring =>
      'Dərhal kontekst lazım olduqda uşağın yaxınlığındakı ətraf səsləri dinləyin.';

  @override
  String get premiumSubtitleScreenTime =>
      'Gündəlik tətbiq limitləri qurun, tətbiqləri bloklayın, sağlam istifadə vərdişlərini tətbiq edin.';

  @override
  String get premiumSubtitleAppStats =>
      'İstifadə statistikasını, tendensiyaları və tətbiq səviyyəsindəki davranış anlayışlarını görün.';

  @override
  String get premiumSubtitleAchievements =>
      'Uşağınız üçün müsbət vərdişlər yaratmaq üçün tapşırıqlar, ulduzlar və mükafatlardan istifadə edin.';

  @override
  String get premiumSubtitleLoudAlarm =>
      'Uşaq cihazını tez tapmaq üçün uzaqdan yüksək həyəcan siqnalı verin.';

  @override
  String get premiumSubtitleFullMenu =>
      'Qabaqcıl valideyn menyusu, idarəetmə vasitələri və izləmə alətləri Pro-nun bir hissəsidir.';

  @override
  String get premiumSubtitleGeneric =>
      'Qabaqcıl valideyn nəzarəti və izləmə alətlərini açmaq üçün Family Security Pro-ya yüksəlin.';

  @override
  String get seePlans => 'Planlara bax';
}
