// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkmen (`tk`).
class STk extends S {
  STk([String locale = 'tk']) : super(locale);

  @override
  String get appName => 'Çaga Howpsuzlygy';

  @override
  String get signInOrCreate => 'Ene-ata hasabyna giriň ýa-da döretdiň';

  @override
  String get signIn => 'Giriş';

  @override
  String get createParentAccount => 'Ene-ata hasabyny dörediň';

  @override
  String get childrenSignInHint =>
      'Çagalar ene-atasy tarapyndan döredilen maglumatlar bilen girýär.';

  @override
  String get createAccount => 'Hasap dörediň';

  @override
  String get displayName => 'Görkezme ady';

  @override
  String get username => 'Ulanyjy ady';

  @override
  String get password => 'Açar söz';

  @override
  String get navMap => 'Karta';

  @override
  String get navActivity => 'Işjeňlik';

  @override
  String get navChat => 'Söhbet';

  @override
  String get navStats => 'Statistika';

  @override
  String get navHome => 'Baş sahypa';

  @override
  String get waitingForLocation =>
      'Çagalaryň ýerini paýlaşmagyna garaşylýar...';

  @override
  String get addChildToTrack => 'Yzarlamagy başlatmak üçin çaga goşuň';

  @override
  String get manageChildren => 'Çagalary dolandyrmak';

  @override
  String get loud => 'GATY';

  @override
  String get around => 'TÖWEREK';

  @override
  String get currentLocation => 'HÄZIRKI ÝER';

  @override
  String messageChild(String childName) {
    return '$childName-a habar iberiň';
  }

  @override
  String get history => 'Geçmiş';

  @override
  String lastUpdated(String time) {
    return 'Soňky täzelenme: $time';
  }

  @override
  String get statusActive => 'IŞJEŇ';

  @override
  String get statusPaused => 'DURUZYLAN';

  @override
  String get statusOffline => 'AWTONOM';

  @override
  String get justNow => 'Indi şu wagt';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min. öň';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours sag. öň';
  }

  @override
  String get active => 'Işjeň';

  @override
  String get inactive => 'Işjeň däl';

  @override
  String get addChildToSeeActivity => 'Işjeňligi görmek üçin çaga goşuň';

  @override
  String get activity => 'Işjeňlik';

  @override
  String get today => 'Şu gün';

  @override
  String get leftArea => 'Sebitden çykdy';

  @override
  String get arrivedAtLocation => 'Ýere geldi';

  @override
  String get phoneCharging => 'Telefon zarýad alýar';

  @override
  String batteryReached(int battery) {
    return 'Batareýa $battery%-e ýetdi';
  }

  @override
  String get batteryLow => 'Batareýa az';

  @override
  String batteryDropped(int battery) {
    return 'Batareýa $battery%-e düşdi';
  }

  @override
  String get currentLocationTitle => 'Häzirki ýer';

  @override
  String get locationShared => 'Ýer paýlaşyldy';

  @override
  String get batteryStatus => 'Batareýa ýagdaýy';

  @override
  String batteryAt(int battery) {
    return 'Batareýa $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Heniz işjeňlik ýok. $childName ýerini paýlaşandan soň wakalar görner.';
  }

  @override
  String get safeZones => 'Howpsuz zolaklary';

  @override
  String get addNew => 'Täze goşuň';

  @override
  String get noSafeZonesYet => 'Heniz howpsuz zolak ýok';

  @override
  String zone(String zoneName) {
    return 'Zolak: $zoneName';
  }

  @override
  String get editZone => 'Zolagy redaktirlemek';

  @override
  String get activeToday => 'BU GÜN IŞJEŇ';

  @override
  String get inactiveToday => 'BU GÜN IŞJEŇ DÄL';

  @override
  String get disabled => 'ÖÇÜRILEN';

  @override
  String get dailySafetyScore => 'Gündelik howpsuzlyk baly';

  @override
  String get noLocationUpdatesYet => 'Şu gün heniz ýer täzelenmeleri ýok';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return 'Şu gün $totalUpdates täzelemeden $inZoneUpdates sanysy howpsuz zolakda boldy';
  }

  @override
  String coverage(int percent) {
    return 'Örtüm: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Häzirki zolak: $zoneName';
  }

  @override
  String get addSafeZone => 'Howpsuz zolak goşuň';

  @override
  String get editSafeZone => 'Howpsuz zolagy redaktirlemek';

  @override
  String get deleteZoneTitle => 'Zolagy pozmaly?';

  @override
  String get deleteZoneMessage => 'Bu hereketi yzyna almak mümkin däl.';

  @override
  String get cancel => 'Ýatyr';

  @override
  String get delete => 'Pozmak';

  @override
  String get zoneEnabled => 'ZOLAK IŞJEŇ';

  @override
  String get zoneName => 'ZOLAGYŇ ADY';

  @override
  String get zoneNameHint => 'mysal: Öý, Mekdep';

  @override
  String get activeWhen => 'HAÇAN IŞJEŇ';

  @override
  String get always => 'Hemişe';

  @override
  String get daysOfWeek => 'Hepdäniň günleri';

  @override
  String get chooseAtLeastOneDay => 'Bu tertip üçin azyndan bir gün saýlaň.';

  @override
  String get radius => 'RADIUS';

  @override
  String get locationMoveMap =>
      'ÝER (Merkezi merkezi goýmak üçin kartany süýşüriň)';

  @override
  String get moveMapToSetCenter =>
      'Zolagyň merkezini bellemek üçin kartany süýşüriň';

  @override
  String get createSafeZone => 'Howpsuz zolak dörediň';

  @override
  String get updateSafeZone => 'Howpsuz zolagy täzelemek';

  @override
  String get pleaseEnterZoneName => 'Zolagyň adyny giriziň';

  @override
  String get chooseAtLeastOneDayError => 'Azyndan bir işjeň gün saýlaň';

  @override
  String get addChildToChat => 'Söhbet başlatmak üçin çaga goşuň';

  @override
  String get noMessagesYet => 'Heniz habar ýok. Salam aýdyň!';

  @override
  String get sendMessage => 'Habar iberiň...';

  @override
  String failedToSend(String error) {
    return 'Iberip bolmady: $error';
  }

  @override
  String helloUser(String name) {
    return 'Salam, $name!';
  }

  @override
  String get kidMode => 'Çaga režimi';

  @override
  String get myLocation => 'Meniň ýerim';

  @override
  String get waitingForGps => 'GPS-i garaşylýar...';

  @override
  String sharedWithParent(String time) {
    return 'Ene-ata bilen paýlaşyldy · $time';
  }

  @override
  String get notSharedYet => 'Heniz paýlaşylmady';

  @override
  String get imSafe => 'Men howpsuz';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Ene-ataňyza \"Men howpsuz\" iberildi';

  @override
  String get sosMessage => 'SOS! Kömek gerek!';

  @override
  String sosLocation(String address) {
    return ' Ýer: $address';
  }

  @override
  String get sosSent => 'SOS iberildi — ene-ata habar berler';

  @override
  String get allowUsageAccess => 'Ulanmak hukukyna rugsat beriň';

  @override
  String get usageAccessDescription =>
      'Bu ene-ata paneline bu telefondan real ekran wagty maglumatlaryny we goýma çäklendirmelerini görkezmäge mümkinçilik berýär.';

  @override
  String get openUsageAccess => 'Ulanmak hukukyny açyň';

  @override
  String syncError(String error) {
    return 'Sinhronlaşdyrma ýalňyşlygy: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone çäklendirmesi';

  @override
  String get iphoneUsageDescription =>
      'iPhone-da Android görnüşli Ulanmak Hukugy ekrany ýok. Hakyky goýma ekran wagty we göni goýma blokirlemesi Apple Screen Time API-lerini we ýörite ygtyýarnamalary talap edýär, şonuň üçin bu düwme iOS-da işlemez.';

  @override
  String get turnOnLocation => 'Ýer hyzmatlaryny açyň';

  @override
  String get locationIsOff =>
      'Ýer öçürilen. Ene-ata bilen paýlaşmak üçin ony açyň.';

  @override
  String get openLocationSettings => 'Ýer sazlamalaryny açyň';

  @override
  String get locationBlocked => 'Ýer rugsady petiklenen';

  @override
  String get enableLocationAccess => 'Ulgam sazlamalarynda ýere girişi açyň.';

  @override
  String get openAppSettings => 'Goýma sazlamalaryny açyň';

  @override
  String get allowLocationToShare => 'Ýer paýlaşmaga rugsat beriň';

  @override
  String get grantLocationPermission =>
      'Ene-ataňyzyň siziň nirededigi görmegi üçin rugsat beriň.';

  @override
  String get allowLocation => 'Ýere rugsat beriň';

  @override
  String get myChildren => 'Meniň çagalarym';

  @override
  String get addChild => 'Çaga goşuň';

  @override
  String get noChildrenYet =>
      'Heniz çaga ýok. Döretmek üçin \"Çaga goşuň\" düwmesine basyň.';

  @override
  String get parentAccount => 'Ene-ata hasaby';

  @override
  String get changePhoto => 'Suraty çalşyň';

  @override
  String get deleteChildTitle => 'Çagany pozmaly?';

  @override
  String deleteChildMessage(String childName) {
    return '$childName we ähli bagly işjeňlik taryhyny pozmaly?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName pozuldy';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Çagany pozmak başartmady: $error';
  }

  @override
  String get avatarUpdated => 'Avatar täzelendi';

  @override
  String failedGeneric(String error) {
    return 'Başartmady: $error';
  }

  @override
  String get createChildAccount => 'Çaga hasabyny dörediň';

  @override
  String get childSignInHint =>
      'Çagaňyz öz enjamynda bu maglumatlar bilen girer.';

  @override
  String get displayNameHint => 'Görkezme ady (mysal: Aleks)';

  @override
  String get create => 'Dörediň';

  @override
  String get editChildProfile => 'Çaganyň profilini redaktirlemek';

  @override
  String get save => 'Saklaň';

  @override
  String get deleteChild => 'Çagany pozmak';

  @override
  String get track => 'Yzarlamak';

  @override
  String get edit => 'Redaktirlemek';

  @override
  String get settings => 'Sazlamalar';

  @override
  String get parent => 'ENE-ATA';

  @override
  String get child => 'ÇAGA';

  @override
  String get editProfileDetails => 'Profil maglumatlaryny redaktirlemek';

  @override
  String get account => 'Hasap';

  @override
  String get manageChildrenMenu => 'Çagalary dolandyrmak';

  @override
  String get editProfile => 'Profili redaktirlemek';

  @override
  String get notifications => 'Bildirişler';

  @override
  String get pushNotifications => 'Öňe itmek bildirişleri';

  @override
  String get locationAlerts => 'Ýer duýduryşlary';

  @override
  String get batteryAlerts => 'Batareýa duýduryşlary';

  @override
  String get safeZoneAlerts => 'Howpsuz zolak duýduryşlary';

  @override
  String get notificationPermissionRequired =>
      'Duýduryş ibermek üçin bildiriş rugsady gerek';

  @override
  String get general => 'Umumy';

  @override
  String get language => 'Dil';

  @override
  String get systemDefault => 'Ulgam dili';

  @override
  String get helpAndSupport => 'Kömek we goldaw';

  @override
  String get about => 'Barada';

  @override
  String get privacyPolicy => 'Gizlinlik syýasaty';

  @override
  String get signOut => 'Çykmak';

  @override
  String get appVersion => 'Çaga Howpsuzlygy v1.0.0';

  @override
  String get editProfileTitle => 'Profili redaktirlemek';

  @override
  String get updateProfileHint =>
      'Görkezme adyňyzy we ulanyjy adyňyzy täzeläň.';

  @override
  String get saveChanges => 'Üýtgetmeleri saklaň';

  @override
  String get usernameCannotBeEmpty => 'Ulanyjy ady boş bolup bilmez';

  @override
  String get profileUpdated => 'Profil täzelendi';

  @override
  String failedToUploadAvatar(String error) {
    return 'Avatary ýüklemek başartmady: $error';
  }

  @override
  String get parentProfile => 'Ene-ata profili';

  @override
  String get addChildForStats =>
      'Göni statistikany görmek üçin ilki çaga hasaby goşuň.';

  @override
  String get insights => 'DÜŞÜNJELER';

  @override
  String childStats(String childName) {
    return '$childName statistikasy';
  }

  @override
  String get deviceStatus => 'Enjam ýagdaýy';

  @override
  String batteryPercent(int battery) {
    return '$battery% batareýa';
  }

  @override
  String get batteryUnknown => 'Batareýa belli däl';

  @override
  String synced(String time) {
    return '$time sinhronlaşdyryldy';
  }

  @override
  String get noDeviceSyncYet => 'Heniz enjam sinhronlaşdyrylmady';

  @override
  String get usageAccessGranted => 'Ulanmak hukugy berildi';

  @override
  String get usageAccessNeeded => 'Ulanmak hukugy gerek';

  @override
  String get iosUsageAccessNote =>
      'Bu çaga enjamy iPhone. iOS Android Ulanmak Hukugyny üpjün etmeýär, şonuň üçin bu goýma ol rugsat ekranyny açyp bilmez. Hakyky iPhone ekran wagty we goýma blokirlemesi Apple Screen Time ygtyýarnamalaryny we aýratyn ýerli integrasiýany talap edýär.';

  @override
  String get androidUsageAccessNote =>
      'Telefondan çaga goýmasyny açyň we ulanmak hukukyna rugsat beriň. Ondan soň ekran wagty, goýma çäklendirmeleri we senenama awtomatiki sinhronlaşdyrlar.';

  @override
  String get dailyUsage => 'Gündelik ulanma';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total / $limit ulanylan';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$date günde $total ulanylan';
  }

  @override
  String get allLimitsInRange => 'Ähli işjeň çäklendirmeler çäklerde';

  @override
  String appLimitExceeded(int count) {
    return 'Şu gün $count goýma çäklendirmesi aşyldy';
  }

  @override
  String get setAppLimitsHint =>
      'Hakyky maksat döretmek üçin aşakda goýma çäklendirmelerini belläň.';

  @override
  String get weeklyUsage => 'Hepdäniň ulanmasy';

  @override
  String get usageCalendar => 'Ulanma senenamasy';

  @override
  String get noAppUsageData => 'Bu gün üçin heniz goýma ulanma maglumaty ýok.';

  @override
  String get grantUsageAccessHint =>
      'Hakyky goýma maglumatlaryny görmek we çäklendirmeleri dolandyrmak üçin çaga telefonynda ulanmak hukukyna rugsat beriň.';

  @override
  String get iosAppLimitsUnavailable =>
      'Bu çaga telefony iPhone. Häzirki goýma gurluşynda Apple Screen Time integrasiýasy ýok, şonuň üçin iOS-da hakyky goýma ulanmasy we göni goýma çäklendirmeleri elýeterli däl.';

  @override
  String get enableDailyLimit => 'Gündelik çäklendirmäni açyň';

  @override
  String get dailyLimit => 'Gündelik çäklendirme';

  @override
  String get saveLimit => 'Çäklendirmäni saklaň';

  @override
  String get manageAppLimits => 'Goýma çäklendirmelerini dolandyrmak';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName $date günde ulanylan';
  }

  @override
  String limitMinutes(String time) {
    return 'Çäklendirme $time';
  }

  @override
  String get noLimit => 'Çäklendirme ýok';

  @override
  String usageTodayOverLimit(String time) {
    return 'Şu gün $time · çäkden aşdy';
  }

  @override
  String usageToday(String time) {
    return 'Şu gün $time';
  }

  @override
  String limitSavedFor(String appName) {
    return '$appName üçin çäklendirme saklandy';
  }

  @override
  String limitDisabledFor(String appName) {
    return '$appName üçin çäklendirme öçürildi';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Çäklendirmäni saklap bolmady: $error';
  }

  @override
  String get mon => 'DÜŞ';

  @override
  String get tue => 'SİŞ';

  @override
  String get wed => 'ÇAR';

  @override
  String get thu => 'PEN';

  @override
  String get fri => 'JUM';

  @override
  String get sat => 'ŞEN';

  @override
  String get sun => 'ÝEK';

  @override
  String get over => 'AŞDY';

  @override
  String get onboardingTitle => 'Hoş geldiňiz!';

  @override
  String get onboardingSubtitle => 'Siz kim?';

  @override
  String get iAmParent => 'Men ene-ata';

  @override
  String get iAmChild => 'Men çaga';

  @override
  String get parentSignIn => 'Giriş';

  @override
  String get parentCreateAccount => 'Hasap döretmek';

  @override
  String get parentAuthSubtitle => 'Maşgalaňyzy dolandyryň we goraň';

  @override
  String get childSignIn => 'Giriş';

  @override
  String get childAuthTitle => 'Salam!';

  @override
  String get childAuthSubtitle => 'Giriş maglumatlaryňyzy ene-ataňyzdan soraň';

  @override
  String get childNavSettings => 'Sazlamalar';

  @override
  String get childProfile => 'Profil';

  @override
  String get childSettingsTitle => 'Sazlamalar';

  @override
  String get childLogout => 'Çykmak';

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
    return 'Join my family circle in Kid Security! Use invite code: $code\n\nhttps://backend21.pythonanywhere.com/invite/$code';
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
