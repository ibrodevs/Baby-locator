// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class SHy extends S {
  SHy([String locale = 'hy']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Մուտք գործեք կամ ստեղծեք ծնողի հաշիվ';

  @override
  String get signIn => 'Մուտք գործել';

  @override
  String get createParentAccount => 'Ստեղծել ծնողի հաշիվ';

  @override
  String get childrenSignInHint =>
      'Երեխաները մուտք են գործում ծնողի ստեղծած տվյալներով։';

  @override
  String get createAccount => 'Ստեղծել հաշիվ';

  @override
  String get displayName => 'Ցուցադրվող անուն';

  @override
  String get username => 'Օգտանուն';

  @override
  String get password => 'Գաղտնաբառ';

  @override
  String get navMap => 'Քարտեզ';

  @override
  String get navActivity => 'Ակտիվություն';

  @override
  String get navChat => 'Չատ';

  @override
  String get navStats => 'Վիճակագրություն';

  @override
  String get navHome => 'Գլխավոր';

  @override
  String get waitingForLocation =>
      'Սպասում ենք, որ երեխաները կիսվեն տեղադրությամբ...';

  @override
  String get addChildToTrack => 'Ավելացրեք երեխայի հաշիվ՝ հետևելու համար';

  @override
  String get manageChildren => 'Կառավարել երեխաներին';

  @override
  String get loud => 'ԲԱՐՁՐ';

  @override
  String get around => 'ՄՈՏԵՐՔՈՒՄ';

  @override
  String get currentLocation => 'ԸՆԹԱՑԻԿ ՏԵՂԱԴՐՈՒԹՅՈՒՆ';

  @override
  String messageChild(String childName) {
    return 'Գրել $childName-ին';
  }

  @override
  String get history => 'Պատմություն';

  @override
  String lastUpdated(String time) {
    return 'Վերջին թարմացումը՝ $time';
  }

  @override
  String get statusActive => 'ԱԿՏԻՎ';

  @override
  String get statusPaused => 'ԴԱԴԱՐԵՑՎԱԾ';

  @override
  String get statusOffline => 'ՕՖԼԱՅՆ';

  @override
  String get justNow => 'Հենց հիմա';

  @override
  String minutesAgo(int minutes) {
    return '$minutes ր. առաջ';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ժ. առաջ';
  }

  @override
  String get active => 'Ակտիվ';

  @override
  String get inactive => 'Ապաակտիվ';

  @override
  String get addChildToSeeActivity =>
      'Ավելացրեք երեխա՝ ակտիվությունը տեսնելու համար';

  @override
  String get activity => 'Ակտիվություն';

  @override
  String get today => 'Այսօր';

  @override
  String get leftArea => 'Լքեց տարածքը';

  @override
  String get arrivedAtLocation => 'Հասավ վայր';

  @override
  String get phoneCharging => 'Հեռախոսը լիցքավորվում է';

  @override
  String batteryReached(int battery) {
    return 'Մարտկոցը հասավ $battery%';
  }

  @override
  String get batteryLow => 'Մարտկոցը թույլ է';

  @override
  String batteryDropped(int battery) {
    return 'Մարտկոցը իջավ մինչև $battery%';
  }

  @override
  String get currentLocationTitle => 'Ընթացիկ տեղադրություն';

  @override
  String get locationShared => 'Տեղադրությունը կիսվել է';

  @override
  String get batteryStatus => 'Մարտկոցի վիճակ';

  @override
  String batteryAt(int battery) {
    return 'Մարտկոցը $battery% է';
  }

  @override
  String noActivityYet(String childName) {
    return 'Դեռ ակտիվություն չկա։ Իրադարձությունները կհայտնվեն, երբ $childName-ը կկիսվի տեղադրությամբ։';
  }

  @override
  String get safeZones => 'Անվտանգ գոտիներ';

  @override
  String get addNew => 'Ավելացնել';

  @override
  String get noSafeZonesYet => 'Դեռ անվտանգ գոտիներ չկան';

  @override
  String zone(String zoneName) {
    return 'Գոտի՝ $zoneName';
  }

  @override
  String get editZone => 'Խմբագրել գոտին';

  @override
  String get activeToday => 'ԱՅՍՕՐ ԱԿՏԻՎ';

  @override
  String get inactiveToday => 'ԱՅՍՕՐ ԱՊԱԱԿՏԻՎ';

  @override
  String get disabled => 'ԱՆՋԱՏՎԱԾ';

  @override
  String get dailySafetyScore => 'Օրվա անվտանգության միավոր';

  @override
  String get noLocationUpdatesYet => 'Այսօր տեղադրության թարմացումներ չկան';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return 'Այսօրվա $totalUpdates թարմացումներից $inZoneUpdates-ը եղել է անվտանգ գոտիներում';
  }

  @override
  String coverage(int percent) {
    return 'Ծածկույթ՝ $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Ընթացիկ գոտի՝ $zoneName';
  }

  @override
  String get addSafeZone => 'Ավելացնել անվտանգ գոտի';

  @override
  String get editSafeZone => 'Խմբագրել անվտանգ գոտին';

  @override
  String get deleteZoneTitle => 'Ջնջե՞լ գոտին';

  @override
  String get deleteZoneMessage => 'Այս գործողությունը հնարավոր չէ հետարկել։';

  @override
  String get cancel => 'Չեղարկել';

  @override
  String get delete => 'Ջնջել';

  @override
  String get zoneEnabled => 'ԳՈՏԻՆ ՄԻԱՑՎԱԾ Է';

  @override
  String get zoneName => 'ԳՈՏՈՒ ԱՆՎԱՆՈՒՄ';

  @override
  String get zoneNameHint => 'օր.՝ Տուն, Դպրոց';

  @override
  String get activeWhen => 'ԵՐԲ Է ԱԿՏԻՎ';

  @override
  String get always => 'Միշտ';

  @override
  String get daysOfWeek => 'Շաբաթվա օրեր';

  @override
  String get chooseAtLeastOneDay =>
      'Ընտրեք առնվազն մեկ օր այս ժամանակացույցի համար։';

  @override
  String get radius => 'ՇԱՎԻՂ';

  @override
  String get locationMoveMap =>
      'ՏԵՂԱԴՐՈՒԹՅՈՒՆ (Տեղաշարժեք քարտեզը՝ կենտրոնը ընտրելու համար)';

  @override
  String get moveMapToSetCenter =>
      'Տեղաշարժեք քարտեզը՝ գոտու կենտրոնը ընտրելու համար';

  @override
  String get createSafeZone => 'Ստեղծել անվտանգ գոտի';

  @override
  String get updateSafeZone => 'Թարմացնել անվտանգ գոտին';

  @override
  String get pleaseEnterZoneName => 'Խնդրում ենք մուտքագրել գոտու անունը';

  @override
  String get chooseAtLeastOneDayError => 'Ընտրեք առնվազն մեկ ակտիվ օր';

  @override
  String get addChildToChat => 'Ավելացրեք երեխա՝ չատը սկսելու համար';

  @override
  String get noMessagesYet => 'Դեռ հաղորդագրություններ չկան։ Ասեք բարև։';

  @override
  String get sendMessage => 'Գրեք հաղորդագրություն...';

  @override
  String failedToSend(String error) {
    return 'Չհաջողվեց ուղարկել․ $error';
  }

  @override
  String helloUser(String name) {
    return 'Բարև, $name!';
  }

  @override
  String get kidMode => 'Երեխայի ռեժիմ';

  @override
  String get myLocation => 'Իմ տեղադրությունը';

  @override
  String get waitingForGps => 'Սպասում ենք GPS-ին...';

  @override
  String sharedWithParent(String time) {
    return 'Կիսվել է ծնողի հետ · $time';
  }

  @override
  String get notSharedYet => 'Դեռ չի կիսվել';

  @override
  String get imSafe => 'Ես ապահով եմ';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe =>
      '\"Ես ապահով եմ\" հաղորդագրությունն ուղարկվեց ձեր ծնողին';

  @override
  String get sosMessage => 'SOS։ Ինձ օգնություն է պետք։';

  @override
  String sosLocation(String address) {
    return ' Տեղադրություն՝ $address';
  }

  @override
  String get sosSent => 'SOS-ն ուղարկվեց — ծնողը կտեղեկացվի';

  @override
  String get allowUsageAccess => 'Թույլատրել օգտագործման հասանելիությունը';

  @override
  String get usageAccessDescription =>
      'Սա թույլ է տալիս ծնողի վահանակին ցույց տալ այս հեռախոսի իրական էկրանային ժամանակը և հավելվածների սահմանափակումները։';

  @override
  String get openUsageAccess => 'Բացել օգտագործման հասանելիությունը';

  @override
  String syncError(String error) {
    return 'Համաժամեցման սխալ․ $error';
  }

  @override
  String get iphoneLimitation => 'iPhone-ի սահմանափակում';

  @override
  String get iphoneUsageDescription =>
      'iPhone-ում Android-ի նման Usage Access էկրան չկա։ Հավելվածների իրական էկրանային ժամանակը և ուղղակի արգելափակումը պահանջում են Apple Screen Time API և հատուկ թույլտվություններ, ուստի այս կոճակը iOS-ում չի աշխատում։';

  @override
  String get turnOnLocation => 'Միացրեք տեղադրության ծառայությունները';

  @override
  String get locationIsOff =>
      'Տեղադրությունը անջատված է։ Միացրեք այն, որպեսզի կիսվեք ծնողի հետ։';

  @override
  String get openLocationSettings => 'Բացել տեղադրության կարգավորումները';

  @override
  String get locationBlocked => 'Տեղադրության թույլտվությունն արգելափակված է';

  @override
  String get enableLocationAccess =>
      'Միացրեք տեղադրության հասանելիությունը համակարգի կարգավորումներում։';

  @override
  String get openAppSettings => 'Բացել հավելվածի կարգավորումները';

  @override
  String get allowLocationToShare =>
      'Թույլատրել տեղադրությունը՝ կիսվելու համար';

  @override
  String get grantLocationPermission =>
      'Տվեք թույլտվություն, որպեսզի ձեր ծնողը տեսնի, թե որտեղ եք դուք։';

  @override
  String get allowLocation => 'Թույլատրել տեղադրությունը';

  @override
  String get myChildren => 'Իմ երեխաները';

  @override
  String get addChild => 'Ավելացնել երեխա';

  @override
  String get noChildrenYet =>
      'Դեռ երեխաներ չկան։ Սեղմեք «Ավելացնել երեխա»՝ հաշիվ ստեղծելու համար։';

  @override
  String get parentAccount => 'Ծնողի հաշիվ';

  @override
  String get changePhoto => 'Փոխել լուսանկարը';

  @override
  String get deleteChildTitle => 'Ջնջե՞լ երեխային';

  @override
  String deleteChildMessage(String childName) {
    return 'Ջնջե՞լ $childName-ին և ամբողջ կապված ակտիվության պատմությունը։';
  }

  @override
  String childDeleted(String childName) {
    return '$childName-ը ջնջվեց';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Չհաջողվեց ջնջել երեխային․ $error';
  }

  @override
  String get avatarUpdated => 'Ավատարը թարմացվեց';

  @override
  String failedGeneric(String error) {
    return 'Սխալ․ $error';
  }

  @override
  String get createChildAccount => 'Ստեղծել երեխայի հաշիվ';

  @override
  String get childSignInHint =>
      'Ձեր երեխան իր սարքում մուտք կգործի այս տվյալներով։';

  @override
  String get displayNameHint => 'Ցուցադրվող անուն (օր.՝ Alex)';

  @override
  String get create => 'Ստեղծել';

  @override
  String get editChildProfile => 'Խմբագրել երեխայի պրոֆիլը';

  @override
  String get save => 'Պահպանել';

  @override
  String get deleteChild => 'Ջնջել երեխային';

  @override
  String get track => 'Հետևել';

  @override
  String get edit => 'Խմբագրել';

  @override
  String get settings => 'Կարգավորումներ';

  @override
  String get parent => 'ԾՆՈՂ';

  @override
  String get child => 'ԵՐԵԽԱ';

  @override
  String get editProfileDetails => 'Խմբագրել պրոֆիլի տվյալները';

  @override
  String get account => 'Հաշիվ';

  @override
  String get manageChildrenMenu => 'Կառավարել երեխաներին';

  @override
  String get editProfile => 'Խմբագրել պրոֆիլը';

  @override
  String get notifications => 'Ծանուցումներ';

  @override
  String get pushNotifications => 'Push ծանուցումներ';

  @override
  String get locationAlerts => 'Տեղադրության ահազանգեր';

  @override
  String get batteryAlerts => 'Մարտկոցի ահազանգեր';

  @override
  String get safeZoneAlerts => 'Անվտանգ գոտու ահազանգեր';

  @override
  String get notificationPermissionRequired =>
      'Ահազանգեր ուղարկելու համար անհրաժեշտ է ծանուցումների թույլտվություն';

  @override
  String get general => 'Ընդհանուր';

  @override
  String get language => 'Լեզու';

  @override
  String get systemDefault => 'Համակարգի լռելյայն';

  @override
  String get helpAndSupport => 'Օգնություն և աջակցություն';

  @override
  String get about => 'Ծրագրի մասին';

  @override
  String get privacyPolicy => 'Գաղտնիության քաղաքականություն';

  @override
  String get signOut => 'Դուրս գալ';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Խմբագրել պրոֆիլը';

  @override
  String get updateProfileHint =>
      'Թարմացրեք ձեր ցուցադրվող անունը և օգտանունը։';

  @override
  String get saveChanges => 'Պահպանել փոփոխությունները';

  @override
  String get usernameCannotBeEmpty => 'Օգտանունը չի կարող դատարկ լինել';

  @override
  String get profileUpdated => 'Պրոֆիլը թարմացվեց';

  @override
  String failedToUploadAvatar(String error) {
    return 'Չհաջողվեց բեռնել ավատարը․ $error';
  }

  @override
  String get parentProfile => 'Ծնողի պրոֆիլ';

  @override
  String get addChildForStats =>
      'Նախ ավելացրեք երեխայի հաշիվ՝ կենդանի վիճակագրությունը տեսնելու համար։';

  @override
  String get insights => 'ՎԵՐԼՈՒԾՈՒԹՅՈՒՆ';

  @override
  String childStats(String childName) {
    return '$childName-ի վիճակագրություն';
  }

  @override
  String get deviceStatus => 'Սարքի վիճակ';

  @override
  String batteryPercent(int battery) {
    return 'Մարտկոց՝ $battery%';
  }

  @override
  String get batteryUnknown => 'Մարտկոցը անհայտ է';

  @override
  String synced(String time) {
    return 'Համաժամեցվել է $time';
  }

  @override
  String get noDeviceSyncYet => 'Սարքը դեռ չի համաժամեցվել';

  @override
  String get usageAccessGranted => 'Օգտագործման հասանելիությունը տրված է';

  @override
  String get usageAccessNeeded => 'Օգտագործման հասանելիությունը անհրաժեշտ է';

  @override
  String get iosUsageAccessNote =>
      'Երեխայի այս սարքը iPhone է։ iOS-ը Android-ի նման Usage Access չի տրամադրում, ուստի հավելվածը չի կարող բացել այդ թույլտվության էկրանը։ iPhone-ի իրական էկրանային ժամանակը և հավելվածների արգելափակումը պահանջում են Apple Screen Time թույլտվություններ և առանձին native ինտեգրում։';

  @override
  String get androidUsageAccessNote =>
      'Բացեք երեխայի հավելվածը հեռախոսում և թույլատրեք օգտագործման հասանելիությունը։ Դրանից հետո էկրանային ժամանակը, հավելվածների սահմանափակումները և օրացույցը ինքնաշխատ կհամաժամեցվեն։';

  @override
  String get dailyUsage => 'Օրվա օգտագործում';

  @override
  String usageOfLimit(String total, String limit) {
    return 'Օգտագործվել է $total / $limit';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$date-ին օգտագործվել է $total';
  }

  @override
  String get allLimitsInRange =>
      'Բոլոր միացված սահմանափակումները նորմայի մեջ են';

  @override
  String appLimitExceeded(int count) {
    return 'Այսօր գերազանցվել է $count հավելվածի սահմանափակում';
  }

  @override
  String get setAppLimitsHint =>
      'Սահմանեք հավելվածների սահմանափակումները ներքևում, որպեսզի սա դառնա իրական նպատակ։';

  @override
  String get weeklyUsage => 'Շաբաթական օգտագործում';

  @override
  String get usageCalendar => 'Օգտագործման օրացույց';

  @override
  String get noAppUsageData =>
      'Այս օրվա համար հավելվածների օգտագործման տվյալներ դեռ չկան։';

  @override
  String get grantUsageAccessHint =>
      'Տվեք օգտագործման հասանելիություն երեխայի հեռախոսում՝ իրական տվյալները տեսնելու և սահմանափակումները կառավարելու համար։';

  @override
  String get iosAppLimitsUnavailable =>
      'Երեխայի այս հեռախոսը iPhone է։ Հավելվածի ընթացիկ տարբերակը դեռ չունի Apple Screen Time ինտեգրում, ուստի iOS-ում հավելվածների իրական օգտագործումը և ուղղակի սահմանափակումները հասանելի չեն։';

  @override
  String get enableDailyLimit => 'Միացնել օրական սահմանափակումը';

  @override
  String get dailyLimit => 'Օրական սահմանափակում';

  @override
  String get saveLimit => 'Պահպանել սահմանափակումը';

  @override
  String get manageAppLimits => 'Կառավարել հավելվածների սահմանափակումները';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$date-ին օգտագործվել է $appName';
  }

  @override
  String limitMinutes(String time) {
    return 'Սահմանափակում՝ $time';
  }

  @override
  String get noLimit => 'Սահմանափակում չկա';

  @override
  String usageTodayOverLimit(String time) {
    return 'Այսօր $time · գերազանցել է սահմանափակումը';
  }

  @override
  String usageToday(String time) {
    return 'Այսօր $time';
  }

  @override
  String limitSavedFor(String appName) {
    return '$appName-ի սահմանափակումը պահպանվեց';
  }

  @override
  String limitDisabledFor(String appName) {
    return '$appName-ի սահմանափակումը անջատվեց';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Չհաջողվեց պահպանել սահմանափակումը․ $error';
  }

  @override
  String get mon => 'ԵԿ';

  @override
  String get tue => 'ԵՔ';

  @override
  String get wed => 'ՉՔ';

  @override
  String get thu => 'ՀՆ';

  @override
  String get fri => 'ՈւՐ';

  @override
  String get sat => 'ՇԲ';

  @override
  String get sun => 'ԿԻ';

  @override
  String get over => 'ԳԵՐԱԶԱՆՑՎԱԾ';

  @override
  String get onboardingTitle => 'Բարի գալուստ!';

  @override
  String get onboardingSubtitle => 'Ո՞վ եք դուք։';

  @override
  String get iAmParent => 'Ես ծնող եմ';

  @override
  String get iAmChild => 'Ես երեխա եմ';

  @override
  String get parentSignIn => 'Մուտք գործել';

  @override
  String get parentCreateAccount => 'Ստեղծել հաշիվ';

  @override
  String get parentAuthSubtitle => 'Կառավարեք և պաշտպանեք ձեր ընտանիքը';

  @override
  String get childSignIn => 'Մուտք գործել';

  @override
  String get childAuthTitle => 'Բարև՛։';

  @override
  String get childAuthSubtitle => 'Խնդրեք ձեր ծնողից մուտքի տվյալները';

  @override
  String get childNavSettings => 'Կարգավորումներ';

  @override
  String get childProfile => 'Պրոֆիլ';

  @override
  String get childSettingsTitle => 'Կարգավորումներ';

  @override
  String get childLogout => 'Դուրս գալ';

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
