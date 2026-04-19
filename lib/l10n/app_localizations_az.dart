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
  String get safeZones => 'Təhlükəsiz zonalar';

  @override
  String get addNew => 'Yeni əlavə et';

  @override
  String get noSafeZonesYet => 'Hələ təhlükəsiz zona yoxdur';

  @override
  String zone(String zoneName) {
    return 'Zona: $zoneName';
  }

  @override
  String get editZone => 'Zonanı redaktə et';

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
    return 'Cari zona: $zoneName';
  }

  @override
  String get addSafeZone => 'Təhlükəsiz zona əlavə et';

  @override
  String get editSafeZone => 'Təhlükəsiz zonanı redaktə et';

  @override
  String get deleteZoneTitle => 'Zona silinsin?';

  @override
  String get deleteZoneMessage => 'Bu əməliyyat geri alına bilməz.';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get delete => 'Sil';

  @override
  String get zoneEnabled => 'ZONA AKTİV';

  @override
  String get zoneName => 'ZONANIN ADI';

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
      'YER (Mərkəz iynəsini qurmaq üçün xəritəni sürüşdürün)';

  @override
  String get moveMapToSetCenter =>
      'Zona mərkəzini təyin etmək üçün xəritəni sürüşdürün';

  @override
  String get createSafeZone => 'Təhlükəsiz zona yarat';

  @override
  String get updateSafeZone => 'Təhlükəsiz zonanı yenilə';

  @override
  String get pleaseEnterZoneName => 'Zəhmət olmasa zona adı daxil edin';

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
  String get safeZoneAlerts => 'Təhlükəsiz zona xəbərdarlıqları';

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
    return 'Join my family circle in Kid Security! Use invite code: $code';
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
  String get enterYourDetails => 'Choose your name, login and password';

  @override
  String get register => 'Register';

  @override
  String get invalidInviteCode => 'Invalid or expired invite code';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get dontHaveCode => 'Have an invite code? Register';
}
