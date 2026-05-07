// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Sign in or create a parent account';

  @override
  String get signIn => 'Sign in';

  @override
  String get createParentAccount => 'Create parent account';

  @override
  String get childrenSignInHint =>
      'Children sign in with credentials created by their parent.';

  @override
  String get createAccount => 'Create account';

  @override
  String get displayName => 'Display name';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get navMap => 'Map';

  @override
  String get navActivity => 'Activity';

  @override
  String get navChat => 'Chat';

  @override
  String get navStats => 'Stats';

  @override
  String get navHome => 'Home';

  @override
  String get waitingForLocation => 'Waiting for children to share location...';

  @override
  String get addChildToTrack => 'Add a child to start tracking';

  @override
  String get manageChildren => 'Manage children';

  @override
  String get loud => 'LOUD';

  @override
  String get around => 'AROUND';

  @override
  String get currentLocation => 'CURRENT LOCATION';

  @override
  String messageChild(String childName) {
    return 'Message $childName';
  }

  @override
  String get history => 'History';

  @override
  String lastUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String get statusActive => 'ACTIVE';

  @override
  String get statusPaused => 'PAUSED';

  @override
  String get statusOffline => 'OFFLINE';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get addChildToSeeActivity => 'Add a child to see activity';

  @override
  String get activity => 'Activity';

  @override
  String get today => 'Today';

  @override
  String get leftArea => 'Left area';

  @override
  String get arrivedAtLocation => 'Arrived at location';

  @override
  String get phoneCharging => 'Phone Charging';

  @override
  String batteryReached(int battery) {
    return 'Battery reached $battery%';
  }

  @override
  String get batteryLow => 'Battery Low';

  @override
  String batteryDropped(int battery) {
    return 'Battery dropped to $battery%';
  }

  @override
  String get currentLocationTitle => 'Current Location';

  @override
  String get locationShared => 'Location shared';

  @override
  String get batteryStatus => 'Battery Status';

  @override
  String batteryAt(int battery) {
    return 'Battery at $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'No activity yet. Events will appear once $childName shares their location.';
  }

  @override
  String get safeZones => 'Places';

  @override
  String get addNew => 'Add New';

  @override
  String get noSafeZonesYet => 'No places yet';

  @override
  String zone(String zoneName) {
    return 'Place: $zoneName';
  }

  @override
  String get editZone => 'Edit place';

  @override
  String get activeToday => 'ACTIVE TODAY';

  @override
  String get inactiveToday => 'INACTIVE TODAY';

  @override
  String get disabled => 'DISABLED';

  @override
  String get dailySafetyScore => 'Daily Safety Score';

  @override
  String get noLocationUpdatesYet => 'No location updates yet today';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates of $totalUpdates updates were inside safe zones today';
  }

  @override
  String coverage(int percent) {
    return 'Coverage: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Current place: $zoneName';
  }

  @override
  String get addSafeZone => 'Add New Place';

  @override
  String get editSafeZone => 'Edit Place';

  @override
  String get deleteZoneTitle => 'Delete place?';

  @override
  String get deleteZoneMessage => 'This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get zoneEnabled => 'PLACE ENABLED';

  @override
  String get zoneName => 'PLACE NAME';

  @override
  String get zoneNameHint => 'e.g. Home, School';

  @override
  String get activeWhen => 'ACTIVE WHEN';

  @override
  String get always => 'Always';

  @override
  String get daysOfWeek => 'Days of week';

  @override
  String get chooseAtLeastOneDay =>
      'Choose at least one day for this schedule.';

  @override
  String get radius => 'RADIUS';

  @override
  String get locationMoveMap => 'LOCATION (Move map to center pin)';

  @override
  String get moveMapToSetCenter => 'Move the map to set the place center';

  @override
  String get createSafeZone => 'Create Place';

  @override
  String get updateSafeZone => 'Update Place';

  @override
  String get pleaseEnterZoneName => 'Please enter a place name';

  @override
  String get chooseAtLeastOneDayError => 'Choose at least one active day';

  @override
  String get addChildToChat => 'Add a child to start chatting';

  @override
  String get noMessagesYet => 'No messages yet. Say hello!';

  @override
  String get sendMessage => 'Send a message...';

  @override
  String failedToSend(String error) {
    return 'Failed to send: $error';
  }

  @override
  String helloUser(String name) {
    return 'Hello, $name!';
  }

  @override
  String get kidMode => 'Kid mode';

  @override
  String get myLocation => 'My Location';

  @override
  String get waitingForGps => 'Waiting for GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Shared with parent · $time';
  }

  @override
  String get notSharedYet => 'Not shared yet';

  @override
  String get imSafe => 'I\'m Safe';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Sent \"I\'m safe\" to your parent';

  @override
  String get sosMessage => 'SOS! I need help!';

  @override
  String sosLocation(String address) {
    return ' Location: $address';
  }

  @override
  String get sosSent => 'SOS sent — parent will be notified';

  @override
  String get allowUsageAccess => 'Allow app usage access';

  @override
  String get usageAccessDescription =>
      'This lets the parent dashboard show real screen-time data and app limits from this phone.';

  @override
  String get openUsageAccess => 'Open Usage Access';

  @override
  String syncError(String error) {
    return 'Sync error: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone limitation';

  @override
  String get iphoneUsageDescription =>
      'On iPhone there is no Android-style Usage Access screen. Real per-app screen time and direct app blocking need Apple Screen Time APIs and special entitlements, so this button cannot work on iOS.';

  @override
  String get turnOnLocation => 'Turn on Location Services';

  @override
  String get locationIsOff =>
      'Location is off. Enable it to share with parent.';

  @override
  String get openLocationSettings => 'Open Location Settings';

  @override
  String get locationBlocked => 'Location permission blocked';

  @override
  String get enableLocationAccess =>
      'Enable location access in system settings.';

  @override
  String get openAppSettings => 'Open App Settings';

  @override
  String get allowLocationToShare => 'Allow location to share';

  @override
  String get grantLocationPermission =>
      'Grant permission so your parent can see where you are.';

  @override
  String get allowLocation => 'Allow Location';

  @override
  String get myChildren => 'My Children';

  @override
  String get addChild => 'Add Child';

  @override
  String get noChildrenYet =>
      'No children yet. Tap \"Add Child\" to create one.';

  @override
  String get parentAccount => 'Parent account';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get deleteChildTitle => 'Delete child?';

  @override
  String deleteChildMessage(String childName) {
    return 'Delete $childName and all linked activity history?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName deleted';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Failed to delete child: $error';
  }

  @override
  String get avatarUpdated => 'Avatar updated';

  @override
  String failedGeneric(String error) {
    return 'Failed: $error';
  }

  @override
  String get createChildAccount => 'Create Child Account';

  @override
  String get childSignInHint =>
      'Your child will sign in with these credentials on their device.';

  @override
  String get displayNameHint => 'Display name (e.g. Alex)';

  @override
  String get create => 'Create';

  @override
  String get editChildProfile => 'Edit Child Profile';

  @override
  String get save => 'Save';

  @override
  String get deleteChild => 'Delete Child';

  @override
  String get track => 'Track';

  @override
  String get edit => 'Edit';

  @override
  String get settings => 'Settings';

  @override
  String get parent => 'PARENT';

  @override
  String get child => 'CHILD';

  @override
  String get editProfileDetails => 'Edit profile details';

  @override
  String get account => 'Account';

  @override
  String get manageChildrenMenu => 'Manage Children';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get locationAlerts => 'Location Alerts';

  @override
  String get batteryAlerts => 'Battery Alerts';

  @override
  String get safeZoneAlerts => 'Place Alerts';

  @override
  String get notificationPermissionRequired =>
      'Notification permission is required to send alerts';

  @override
  String get general => 'General';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get signOut => 'Sign Out';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get updateProfileHint => 'Update your display name and username.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get usernameCannotBeEmpty => 'Username cannot be empty';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String failedToUploadAvatar(String error) {
    return 'Failed to upload avatar: $error';
  }

  @override
  String get parentProfile => 'Parent Profile';

  @override
  String get addChildForStats => 'Add a child account first to see live stats.';

  @override
  String get insights => 'INSIGHTS';

  @override
  String childStats(String childName) {
    return '$childName\'s Stats';
  }

  @override
  String get deviceStatus => 'Device Status';

  @override
  String batteryPercent(int battery) {
    return '$battery% battery';
  }

  @override
  String get batteryUnknown => 'Battery unknown';

  @override
  String synced(String time) {
    return 'Synced $time';
  }

  @override
  String get noDeviceSyncYet => 'No device sync yet';

  @override
  String get usageAccessGranted => 'Usage access granted';

  @override
  String get usageAccessNeeded => 'Usage access needed';

  @override
  String get iosUsageAccessNote =>
      'This child device is an iPhone. iOS does not provide Android Usage Access, so this app cannot open that permission screen. Real iPhone screen time and app blocking need Apple Screen Time entitlements and a separate native integration.';

  @override
  String get androidUsageAccessNote =>
      'Open the child app on the phone and allow usage access. After that, screen time, app limits, and the calendar will sync automatically.';

  @override
  String get dailyUsage => 'Daily Usage';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total of $limit used';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total used on $date';
  }

  @override
  String get allLimitsInRange => 'All enabled limits are within range';

  @override
  String appLimitExceeded(int count) {
    return '$count app limit exceeded today';
  }

  @override
  String get setAppLimitsHint =>
      'Set app limits below to turn this into a real goal.';

  @override
  String get weeklyUsage => 'Weekly Usage';

  @override
  String get usageCalendar => 'Usage Calendar';

  @override
  String get noAppUsageData => 'No app usage data for this day yet.';

  @override
  String get grantUsageAccessHint =>
      'Grant usage access on the child phone to see real app data and manage limits.';

  @override
  String get iosAppLimitsUnavailable =>
      'This child phone is an iPhone. The current app build does not have Apple Screen Time integration yet, so real per-app usage and direct app limits are unavailable on iOS.';

  @override
  String get enableDailyLimit => 'Enable daily limit';

  @override
  String get dailyLimit => 'Daily limit';

  @override
  String get saveLimit => 'Save limit';

  @override
  String get manageAppLimits => 'Manage App Limits';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName used on $date';
  }

  @override
  String limitMinutes(String time) {
    return 'Limit $time';
  }

  @override
  String get noLimit => 'No limit';

  @override
  String usageTodayOverLimit(String time) {
    return '$time today · over limit';
  }

  @override
  String usageToday(String time) {
    return '$time today';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Limit saved for $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Limit disabled for $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Could not save limit: $error';
  }

  @override
  String get mon => 'MON';

  @override
  String get tue => 'TUE';

  @override
  String get wed => 'WED';

  @override
  String get thu => 'THU';

  @override
  String get fri => 'FRI';

  @override
  String get sat => 'SAT';

  @override
  String get sun => 'SUN';

  @override
  String get over => 'OVER';

  @override
  String get onboardingTitle => 'Welcome!';

  @override
  String get onboardingSubtitle => 'Who are you?';

  @override
  String get iAmParent => 'I\'m a Parent';

  @override
  String get iAmChild => 'I\'m a Child';

  @override
  String get parentSignIn => 'Sign In';

  @override
  String get parentCreateAccount => 'Create Account';

  @override
  String get parentAuthSubtitle => 'Manage and protect your family';

  @override
  String get childSignIn => 'Sign In';

  @override
  String get childAuthTitle => 'Hey there!';

  @override
  String get childAuthSubtitle => 'Ask your parent for the invite code';

  @override
  String get childNavSettings => 'Settings';

  @override
  String get childProfile => 'Profile';

  @override
  String get childSettingsTitle => 'Settings';

  @override
  String get childLogout => 'Log Out';

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

  @override
  String get placesOnMap => 'Places on the map';

  @override
  String get placesAndChildren => 'Places and children';

  @override
  String placesCount(int count) {
    return 'Places: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Active today: $count';
  }

  @override
  String get retry => 'Retry';

  @override
  String get createPlaceHint =>
      'Create a place to receive notifications when your child arrives or leaves.';

  @override
  String get untitledPlace => 'Untitled place';

  @override
  String get placeDeleted => 'Place deleted.';

  @override
  String get editLabel => 'Edit';

  @override
  String get disabledSchedule => 'Disabled';

  @override
  String get noDaysSelected => 'No days selected';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Radius $radius • $schedule';
  }
}
