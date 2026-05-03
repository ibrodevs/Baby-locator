// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Georgian (`ka`).
class SKa extends S {
  SKa([String locale = 'ka']) : super(locale);

  @override
  String get appName => 'Kid Security';

  @override
  String get signInOrCreate => 'შედით ან შექმენით მშობლის ანგარიში';

  @override
  String get signIn => 'შესვლა';

  @override
  String get createParentAccount => 'მშობლის ანგარიშის შექმნა';

  @override
  String get childrenSignInHint =>
      'ბავშვები შედიან მშობლის მიერ შექმნილი მონაცემებით.';

  @override
  String get createAccount => 'ანგარიშის შექმნა';

  @override
  String get displayName => 'საჩვენებელი სახელი';

  @override
  String get username => 'მომხმარებლის სახელი';

  @override
  String get password => 'პაროლი';

  @override
  String get navMap => 'რუკა';

  @override
  String get navActivity => 'აქტივობა';

  @override
  String get navChat => 'ჩატი';

  @override
  String get navStats => 'სტატისტიკა';

  @override
  String get navHome => 'მთავარი';

  @override
  String get waitingForLocation =>
      'ველოდებით, როდის გააზიარებენ ბავშვები მდებარეობას...';

  @override
  String get addChildToTrack => 'მონიტორინგის დასაწყებად დაამატეთ ბავშვი';

  @override
  String get manageChildren => 'ბავშვების მართვა';

  @override
  String get loud => 'ხმამაღლა';

  @override
  String get around => 'ახლოს';

  @override
  String get currentLocation => 'მიმდინარე მდებარეობა';

  @override
  String messageChild(String childName) {
    return 'მისწერეთ $childName-ს';
  }

  @override
  String get history => 'ისტორია';

  @override
  String lastUpdated(String time) {
    return 'ბოლო განახლება: $time';
  }

  @override
  String get statusActive => 'აქტიური';

  @override
  String get statusPaused => 'პაუზაზე';

  @override
  String get statusOffline => 'ოფლაინ';

  @override
  String get justNow => 'ახლახან';

  @override
  String minutesAgo(int minutes) {
    return '$minutes წთ წინ';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours სთ წინ';
  }

  @override
  String get active => 'აქტიური';

  @override
  String get inactive => 'არააქტიური';

  @override
  String get addChildToSeeActivity => 'აქტივობის სანახავად დაამატეთ ბავშვი';

  @override
  String get activity => 'აქტივობა';

  @override
  String get today => 'დღეს';

  @override
  String get leftArea => 'დატოვა ზონა';

  @override
  String get arrivedAtLocation => 'ადგილზე მივიდა';

  @override
  String get phoneCharging => 'ტელეფონი იტენება';

  @override
  String batteryReached(int battery) {
    return 'ბატარეამ მიაღწია $battery%-ს';
  }

  @override
  String get batteryLow => 'ბატარეა დაბალია';

  @override
  String batteryDropped(int battery) {
    return 'ბატარეა დაეცა $battery%-მდე';
  }

  @override
  String get currentLocationTitle => 'მიმდინარე მდებარეობა';

  @override
  String get locationShared => 'მდებარეობა გაზიარებულია';

  @override
  String get batteryStatus => 'ბატარეის მდგომარეობა';

  @override
  String batteryAt(int battery) {
    return 'ბატარეა $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'აქტივობა ჯერ არ არის. მოვლენები გამოჩნდება, როცა $childName მდებარეობას გააზიარებს.';
  }

  @override
  String get safeZones => 'უსაფრთხო ზონები';

  @override
  String get addNew => 'დამატება';

  @override
  String get noSafeZonesYet => 'უსაფრთხო ზონები ჯერ არ არის';

  @override
  String zone(String zoneName) {
    return 'ზონა: $zoneName';
  }

  @override
  String get editZone => 'ზონის რედაქტირება';

  @override
  String get activeToday => 'დღეს აქტიურია';

  @override
  String get inactiveToday => 'დღეს არააქტიურია';

  @override
  String get disabled => 'გამორთულია';

  @override
  String get dailySafetyScore => 'დღიური უსაფრთხოების ქულა';

  @override
  String get noLocationUpdatesYet => 'დღეს მდებარეობის განახლებები არ არის';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return 'დღევანდელი $totalUpdates განახლებიდან $inZoneUpdates იყო უსაფრთხო ზონებში';
  }

  @override
  String coverage(int percent) {
    return 'დაფარვა: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'მიმდინარე ზონა: $zoneName';
  }

  @override
  String get addSafeZone => 'უსაფრთხო ზონის დამატება';

  @override
  String get editSafeZone => 'უსაფრთხო ზონის რედაქტირება';

  @override
  String get deleteZoneTitle => 'წავშალოთ ზონა?';

  @override
  String get deleteZoneMessage => 'ეს მოქმედება ვეღარ გაუქმდება.';

  @override
  String get cancel => 'გაუქმება';

  @override
  String get delete => 'წაშლა';

  @override
  String get zoneEnabled => 'ზონა ჩართულია';

  @override
  String get zoneName => 'ზონის სახელი';

  @override
  String get zoneNameHint => 'მაგ.: სახლი, სკოლა';

  @override
  String get activeWhen => 'როდის არის აქტიური';

  @override
  String get always => 'ყოველთვის';

  @override
  String get daysOfWeek => 'კვირის დღეები';

  @override
  String get chooseAtLeastOneDay => 'ამ განრიგისთვის აირჩიეთ მინიმუმ ერთი დღე.';

  @override
  String get radius => 'რადიუსი';

  @override
  String get locationMoveMap =>
      'მდებარეობა (ცენტრის ასარჩევად გადაადგილეთ რუკა)';

  @override
  String get moveMapToSetCenter => 'ზონის ცენტრის ასარჩევად გადაადგილეთ რუკა';

  @override
  String get createSafeZone => 'უსაფრთხო ზონის შექმნა';

  @override
  String get updateSafeZone => 'უსაფრთხო ზონის განახლება';

  @override
  String get pleaseEnterZoneName => 'გთხოვთ, შეიყვანოთ ზონის სახელი';

  @override
  String get chooseAtLeastOneDayError => 'აირჩიეთ მინიმუმ ერთი აქტიური დღე';

  @override
  String get addChildToChat => 'ჩატის დასაწყებად დაამატეთ ბავშვი';

  @override
  String get noMessagesYet => 'შეტყობინებები ჯერ არ არის. უთხარით გამარჯობა!';

  @override
  String get sendMessage => 'დაწერეთ შეტყობინება...';

  @override
  String failedToSend(String error) {
    return 'გაგზავნა ვერ მოხერხდა: $error';
  }

  @override
  String helloUser(String name) {
    return 'გამარჯობა, $name!';
  }

  @override
  String get kidMode => 'ბავშვის რეჟიმი';

  @override
  String get myLocation => 'ჩემი მდებარეობა';

  @override
  String get waitingForGps => 'GPS-ს ველოდებით...';

  @override
  String sharedWithParent(String time) {
    return 'გაზიარებულია მშობელთან · $time';
  }

  @override
  String get notSharedYet => 'ჯერ არ გაზიარებულა';

  @override
  String get imSafe => 'უსაფრთხოდ ვარ';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => '\"უსაფრთხოდ ვარ\" გაიგზავნა თქვენს მშობელთან';

  @override
  String get sosMessage => 'SOS! დახმარება მჭირდება!';

  @override
  String sosLocation(String address) {
    return ' მდებარეობა: $address';
  }

  @override
  String get sosSent => 'SOS გაიგზავნა — მშობელი გაფრთხილდება';

  @override
  String get allowUsageAccess => 'გამოყენების წვდომის ჩართვა';

  @override
  String get usageAccessDescription =>
      'ეს მშობლის პანელს აძლევს საშუალებას აჩვენოს ამ ტელეფონის ეკრანთან გატარებული დრო და აპების ლიმიტები.';

  @override
  String get openUsageAccess => 'გამოყენების წვდომის გახსნა';

  @override
  String syncError(String error) {
    return 'სინქრონიზაციის შეცდომა: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone-ის შეზღუდვა';

  @override
  String get iphoneUsageDescription =>
      'iPhone-ზე Android-ის მსგავსად Usage Access ფანჯარა არ არსებობს. თითოეული აპის რეალური ეკრანთან გატარებული დრო და პირდაპირი დაბლოკვა საჭიროებს Apple Screen Time API-სა და სპეციალურ უფლებებს, ამიტომ ეს ღილაკი iOS-ზე არ მუშაობს.';

  @override
  String get turnOnLocation => 'ჩართეთ მდებარეობის სერვისები';

  @override
  String get locationIsOff =>
      'მდებარეობა გამორთულია. ჩართეთ, რათა მშობელს გაუზიაროთ.';

  @override
  String get openLocationSettings => 'მდებარეობის პარამეტრების გახსნა';

  @override
  String get locationBlocked => 'მდებარეობის წვდომა დაბლოკილია';

  @override
  String get enableLocationAccess =>
      'ჩართეთ მდებარეობის წვდომა სისტემის პარამეტრებში.';

  @override
  String get openAppSettings => 'აპის პარამეტრების გახსნა';

  @override
  String get allowLocationToShare => 'გაზიარებისთვის დაუშვით მდებარეობა';

  @override
  String get grantLocationPermission =>
      'მიანიჭეთ ნებართვა, რათა მშობელმა დაინახოს, სად ხართ.';

  @override
  String get allowLocation => 'მდებარეობის დაშვება';

  @override
  String get myChildren => 'ჩემი ბავშვები';

  @override
  String get addChild => 'ბავშვის დამატება';

  @override
  String get noChildrenYet =>
      'ბავშვები ჯერ არ არის. ახალი პროფილის შესაქმნელად დააჭირეთ „ბავშვის დამატებას“.';

  @override
  String get parentAccount => 'მშობლის ანგარიში';

  @override
  String get changePhoto => 'ფოტოს შეცვლა';

  @override
  String get deleteChildTitle => 'წავშალოთ ბავშვი?';

  @override
  String deleteChildMessage(String childName) {
    return 'წავშალოთ $childName და მასთან დაკავშირებული აქტივობის მთელი ისტორია?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName წაიშალა';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'ბავშვის წაშლა ვერ მოხერხდა: $error';
  }

  @override
  String get avatarUpdated => 'ავატარი განახლდა';

  @override
  String failedGeneric(String error) {
    return 'შეცდომა: $error';
  }

  @override
  String get createChildAccount => 'ბავშვის ანგარიშის შექმნა';

  @override
  String get childSignInHint =>
      'თქვენი ბავშვი თავის მოწყობილობაზე შევა ამ მონაცემებით.';

  @override
  String get displayNameHint => 'საჩვენებელი სახელი (მაგ.: Alex)';

  @override
  String get create => 'შექმნა';

  @override
  String get editChildProfile => 'ბავშვის პროფილის რედაქტირება';

  @override
  String get save => 'შენახვა';

  @override
  String get deleteChild => 'ბავშვის წაშლა';

  @override
  String get track => 'თვალთვალი';

  @override
  String get edit => 'რედაქტირება';

  @override
  String get settings => 'პარამეტრები';

  @override
  String get parent => 'მშობელი';

  @override
  String get child => 'ბავშვი';

  @override
  String get editProfileDetails => 'პროფილის დეტალების რედაქტირება';

  @override
  String get account => 'ანგარიში';

  @override
  String get manageChildrenMenu => 'ბავშვების მართვა';

  @override
  String get editProfile => 'პროფილის რედაქტირება';

  @override
  String get notifications => 'შეტყობინებები';

  @override
  String get pushNotifications => 'Push შეტყობინებები';

  @override
  String get locationAlerts => 'მდებარეობის გაფრთხილებები';

  @override
  String get batteryAlerts => 'ბატარეის გაფრთხილებები';

  @override
  String get safeZoneAlerts => 'უსაფრთხო ზონის გაფრთხილებები';

  @override
  String get notificationPermissionRequired =>
      'გაფრთხილებების გასაგზავნად საჭიროა შეტყობინებების ნებართვა';

  @override
  String get general => 'ზოგადი';

  @override
  String get language => 'ენა';

  @override
  String get systemDefault => 'სისტემური ნაგულისხმევი';

  @override
  String get helpAndSupport => 'დახმარება და მხარდაჭერა';

  @override
  String get about => 'აპის შესახებ';

  @override
  String get privacyPolicy => 'კონფიდენციალურობის პოლიტიკა';

  @override
  String get signOut => 'გასვლა';

  @override
  String get appVersion => 'Kid Security v1.0.0';

  @override
  String get editProfileTitle => 'პროფილის რედაქტირება';

  @override
  String get updateProfileHint =>
      'განაახლეთ თქვენი საჩვენებელი სახელი და მომხმარებლის სახელი.';

  @override
  String get saveChanges => 'ცვლილებების შენახვა';

  @override
  String get usernameCannotBeEmpty => 'მომხმარებლის სახელი ცარიელი ვერ იქნება';

  @override
  String get profileUpdated => 'პროფილი განახლდა';

  @override
  String failedToUploadAvatar(String error) {
    return 'ავატარის ატვირთვა ვერ მოხერხდა: $error';
  }

  @override
  String get parentProfile => 'მშობლის პროფილი';

  @override
  String get addChildForStats =>
      'ცოცხალი სტატისტიკის სანახავად ჯერ დაამატეთ ბავშვის ანგარიში.';

  @override
  String get insights => 'ანალიტიკა';

  @override
  String childStats(String childName) {
    return '$childName-ის სტატისტიკა';
  }

  @override
  String get deviceStatus => 'მოწყობილობის მდგომარეობა';

  @override
  String batteryPercent(int battery) {
    return 'ბატარეა $battery%';
  }

  @override
  String get batteryUnknown => 'ბატარეა უცნობია';

  @override
  String synced(String time) {
    return 'სინქრონიზებულია $time';
  }

  @override
  String get noDeviceSyncYet => 'მოწყობილობა ჯერ არ დასინქრონებულა';

  @override
  String get usageAccessGranted => 'გამოყენების წვდომა ჩართულია';

  @override
  String get usageAccessNeeded => 'საჭიროა გამოყენების წვდომა';

  @override
  String get iosUsageAccessNote =>
      'ეს ბავშვის მოწყობილობა iPhone-ია. iOS არ იძლევა Android-ის მსგავს Usage Access-ს, ამიტომ აპი ვერ ხსნის ამ ნებართვის ფანჯარას. iPhone-ზე რეალური ეკრანთან გატარებული დრო და აპების დაბლოკვა საჭიროებს Apple Screen Time-ის უფლებებს და ცალკე native ინტეგრაციას.';

  @override
  String get androidUsageAccessNote =>
      'გახსენით ბავშვის აპი ტელეფონზე და დაუშვით გამოყენების წვდომა. ამის შემდეგ ეკრანთან გატარებული დრო, აპების ლიმიტები და კალენდარი ავტომატურად დასინქრონდება.';

  @override
  String get dailyUsage => 'დღიური გამოყენება';

  @override
  String usageOfLimit(String total, String limit) {
    return 'გამოყენებულია $total / $limit';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$date-ზე გამოყენებულია $total';
  }

  @override
  String get allLimitsInRange => 'ყველა ჩართული ლიმიტი ნორმაშია';

  @override
  String appLimitExceeded(int count) {
    return 'დღეს გადაჭარბდა $count აპის ლიმიტი';
  }

  @override
  String get setAppLimitsHint =>
      'ქვემოთ დააყენეთ აპების ლიმიტები, რომ ეს რეალურ მიზნად იქცეს.';

  @override
  String get weeklyUsage => 'კვირის გამოყენება';

  @override
  String get usageCalendar => 'გამოყენების კალენდარი';

  @override
  String get noAppUsageData =>
      'ამ დღისთვის აპების გამოყენების მონაცემები ჯერ არ არის.';

  @override
  String get grantUsageAccessHint =>
      'რეალური აპების მონაცემების სანახავად და ლიმიტების სამართავად ბავშვის ტელეფონზე დაუშვით გამოყენების წვდომა.';

  @override
  String get iosAppLimitsUnavailable =>
      'ბავშვის ეს ტელეფონი iPhone-ია. აპის მიმდინარე ვერსიას ჯერ არ აქვს Apple Screen Time ინტეგრაცია, ამიტომ iOS-ზე აპების რეალური გამოყენება და პირდაპირი ლიმიტები მიუწვდომელია.';

  @override
  String get enableDailyLimit => 'დღიური ლიმიტის ჩართვა';

  @override
  String get dailyLimit => 'დღიური ლიმიტი';

  @override
  String get saveLimit => 'ლიმიტის შენახვა';

  @override
  String get manageAppLimits => 'აპების ლიმიტების მართვა';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$date-ზე გამოყენებულია $appName';
  }

  @override
  String limitMinutes(String time) {
    return 'ლიმიტი $time';
  }

  @override
  String get noLimit => 'ლიმიტის გარეშე';

  @override
  String usageTodayOverLimit(String time) {
    return 'დღეს $time · ლიმიტს გადააჭარბა';
  }

  @override
  String usageToday(String time) {
    return 'დღეს $time';
  }

  @override
  String limitSavedFor(String appName) {
    return '$appName-ისთვის ლიმიტი შენახულია';
  }

  @override
  String limitDisabledFor(String appName) {
    return '$appName-ისთვის ლიმიტი გამორთულია';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'ლიმიტის შენახვა ვერ მოხერხდა: $error';
  }

  @override
  String get mon => 'ორშ';

  @override
  String get tue => 'სამშ';

  @override
  String get wed => 'ოთხ';

  @override
  String get thu => 'ხუთ';

  @override
  String get fri => 'პარ';

  @override
  String get sat => 'შაბ';

  @override
  String get sun => 'კვი';

  @override
  String get over => 'გადაცილებულია';

  @override
  String get onboardingTitle => 'კეთილი იყოს თქვენი მობრძანება!';

  @override
  String get onboardingSubtitle => 'ვინ ხარ?';

  @override
  String get iAmParent => 'მე მშობელი ვარ';

  @override
  String get iAmChild => 'მე ბავშვი ვარ';

  @override
  String get parentSignIn => 'შესვლა';

  @override
  String get parentCreateAccount => 'ანგარიშის შექმნა';

  @override
  String get parentAuthSubtitle => 'მართეთ და დაიცავით თქვენი ოჯახი';

  @override
  String get childSignIn => 'შესვლა';

  @override
  String get childAuthTitle => 'გამარჯობა!';

  @override
  String get childAuthSubtitle => 'შესასვლელი მონაცემები მშობელს ჰკითხე';

  @override
  String get childNavSettings => 'პარამეტრები';

  @override
  String get childProfile => 'პროფილი';

  @override
  String get childSettingsTitle => 'პარამეტრები';

  @override
  String get childLogout => 'გასვლა';

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
