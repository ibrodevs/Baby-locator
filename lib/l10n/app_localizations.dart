import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_az.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ka.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tg.dart';
import 'app_localizations_tk.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('az'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hy'),
    Locale('it'),
    Locale('ka'),
    Locale('kk'),
    Locale('ky'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tg'),
    Locale('tk'),
    Locale('uz')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Kid Security'**
  String get appName;

  /// No description provided for @signInOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create a parent account'**
  String get signInOrCreate;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createParentAccount.
  ///
  /// In en, this message translates to:
  /// **'Create parent account'**
  String get createParentAccount;

  /// No description provided for @childrenSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Children sign in with credentials created by their parent.'**
  String get childrenSignInHint;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @waitingForLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for children to share location...'**
  String get waitingForLocation;

  /// No description provided for @addChildToTrack.
  ///
  /// In en, this message translates to:
  /// **'Add a child to start tracking'**
  String get addChildToTrack;

  /// No description provided for @manageChildren.
  ///
  /// In en, this message translates to:
  /// **'Manage children'**
  String get manageChildren;

  /// No description provided for @loud.
  ///
  /// In en, this message translates to:
  /// **'LOUD'**
  String get loud;

  /// No description provided for @around.
  ///
  /// In en, this message translates to:
  /// **'AROUND'**
  String get around;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'CURRENT LOCATION'**
  String get currentLocation;

  /// No description provided for @messageChild.
  ///
  /// In en, this message translates to:
  /// **'Message {childName}'**
  String messageChild(String childName);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {time}'**
  String lastUpdated(String time);

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get statusActive;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get statusPaused;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get statusOffline;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @addChildToSeeActivity.
  ///
  /// In en, this message translates to:
  /// **'Add a child to see activity'**
  String get addChildToSeeActivity;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @leftArea.
  ///
  /// In en, this message translates to:
  /// **'Left area'**
  String get leftArea;

  /// No description provided for @arrivedAtLocation.
  ///
  /// In en, this message translates to:
  /// **'Arrived at location'**
  String get arrivedAtLocation;

  /// No description provided for @phoneCharging.
  ///
  /// In en, this message translates to:
  /// **'Phone Charging'**
  String get phoneCharging;

  /// No description provided for @batteryReached.
  ///
  /// In en, this message translates to:
  /// **'Battery reached {battery}%'**
  String batteryReached(int battery);

  /// No description provided for @batteryLow.
  ///
  /// In en, this message translates to:
  /// **'Battery Low'**
  String get batteryLow;

  /// No description provided for @batteryDropped.
  ///
  /// In en, this message translates to:
  /// **'Battery dropped to {battery}%'**
  String batteryDropped(int battery);

  /// No description provided for @currentLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocationTitle;

  /// No description provided for @locationShared.
  ///
  /// In en, this message translates to:
  /// **'Location shared'**
  String get locationShared;

  /// No description provided for @batteryStatus.
  ///
  /// In en, this message translates to:
  /// **'Battery Status'**
  String get batteryStatus;

  /// No description provided for @batteryAt.
  ///
  /// In en, this message translates to:
  /// **'Battery at {battery}%'**
  String batteryAt(int battery);

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet. Events will appear once {childName} shares their location.'**
  String noActivityYet(String childName);

  /// No description provided for @safeZones.
  ///
  /// In en, this message translates to:
  /// **'Safe Zones'**
  String get safeZones;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @noSafeZonesYet.
  ///
  /// In en, this message translates to:
  /// **'No safe zones yet'**
  String get noSafeZonesYet;

  /// No description provided for @zone.
  ///
  /// In en, this message translates to:
  /// **'Zone: {zoneName}'**
  String zone(String zoneName);

  /// No description provided for @editZone.
  ///
  /// In en, this message translates to:
  /// **'Edit Zone'**
  String get editZone;

  /// No description provided for @activeToday.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TODAY'**
  String get activeToday;

  /// No description provided for @inactiveToday.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE TODAY'**
  String get inactiveToday;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'DISABLED'**
  String get disabled;

  /// No description provided for @dailySafetyScore.
  ///
  /// In en, this message translates to:
  /// **'Daily Safety Score'**
  String get dailySafetyScore;

  /// No description provided for @noLocationUpdatesYet.
  ///
  /// In en, this message translates to:
  /// **'No location updates yet today'**
  String get noLocationUpdatesYet;

  /// No description provided for @safetyScoreDetails.
  ///
  /// In en, this message translates to:
  /// **'{inZoneUpdates} of {totalUpdates} updates were inside safe zones today'**
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates);

  /// No description provided for @coverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage: {percent}%'**
  String coverage(int percent);

  /// No description provided for @currentZone.
  ///
  /// In en, this message translates to:
  /// **'Current zone: {zoneName}'**
  String currentZone(String zoneName);

  /// No description provided for @addSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Add Safe Zone'**
  String get addSafeZone;

  /// No description provided for @editSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Edit Safe Zone'**
  String get editSafeZone;

  /// No description provided for @deleteZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Zone?'**
  String get deleteZoneTitle;

  /// No description provided for @deleteZoneMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteZoneMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @zoneEnabled.
  ///
  /// In en, this message translates to:
  /// **'ZONE ENABLED'**
  String get zoneEnabled;

  /// No description provided for @zoneName.
  ///
  /// In en, this message translates to:
  /// **'ZONE NAME'**
  String get zoneName;

  /// No description provided for @zoneNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, School'**
  String get zoneNameHint;

  /// No description provided for @activeWhen.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE WHEN'**
  String get activeWhen;

  /// No description provided for @always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// No description provided for @daysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Days of week'**
  String get daysOfWeek;

  /// No description provided for @chooseAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one day for this schedule.'**
  String get chooseAtLeastOneDay;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'RADIUS'**
  String get radius;

  /// No description provided for @locationMoveMap.
  ///
  /// In en, this message translates to:
  /// **'LOCATION (Move map to center pin)'**
  String get locationMoveMap;

  /// No description provided for @moveMapToSetCenter.
  ///
  /// In en, this message translates to:
  /// **'Move the map to set zone center'**
  String get moveMapToSetCenter;

  /// No description provided for @createSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Create Safe Zone'**
  String get createSafeZone;

  /// No description provided for @updateSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Update Safe Zone'**
  String get updateSafeZone;

  /// No description provided for @pleaseEnterZoneName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a zone name'**
  String get pleaseEnterZoneName;

  /// No description provided for @chooseAtLeastOneDayError.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one active day'**
  String get chooseAtLeastOneDayError;

  /// No description provided for @addChildToChat.
  ///
  /// In en, this message translates to:
  /// **'Add a child to start chatting'**
  String get addChildToChat;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get noMessagesYet;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message...'**
  String get sendMessage;

  /// No description provided for @failedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String failedToSend(String error);

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String helloUser(String name);

  /// No description provided for @kidMode.
  ///
  /// In en, this message translates to:
  /// **'Kid mode'**
  String get kidMode;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @waitingForGps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS...'**
  String get waitingForGps;

  /// No description provided for @sharedWithParent.
  ///
  /// In en, this message translates to:
  /// **'Shared with parent · {time}'**
  String sharedWithParent(String time);

  /// No description provided for @notSharedYet.
  ///
  /// In en, this message translates to:
  /// **'Not shared yet'**
  String get notSharedYet;

  /// No description provided for @imSafe.
  ///
  /// In en, this message translates to:
  /// **'I\'m Safe'**
  String get imSafe;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @sentImSafe.
  ///
  /// In en, this message translates to:
  /// **'Sent \"I\'m safe\" to your parent'**
  String get sentImSafe;

  /// No description provided for @sosMessage.
  ///
  /// In en, this message translates to:
  /// **'SOS! I need help!'**
  String get sosMessage;

  /// No description provided for @sosLocation.
  ///
  /// In en, this message translates to:
  /// **' Location: {address}'**
  String sosLocation(String address);

  /// No description provided for @sosSent.
  ///
  /// In en, this message translates to:
  /// **'SOS sent — parent will be notified'**
  String get sosSent;

  /// No description provided for @allowUsageAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow app usage access'**
  String get allowUsageAccess;

  /// No description provided for @usageAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'This lets the parent dashboard show real screen-time data and app limits from this phone.'**
  String get usageAccessDescription;

  /// No description provided for @openUsageAccess.
  ///
  /// In en, this message translates to:
  /// **'Open Usage Access'**
  String get openUsageAccess;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error: {error}'**
  String syncError(String error);

  /// No description provided for @iphoneLimitation.
  ///
  /// In en, this message translates to:
  /// **'iPhone limitation'**
  String get iphoneLimitation;

  /// No description provided for @iphoneUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'On iPhone there is no Android-style Usage Access screen. Real per-app screen time and direct app blocking need Apple Screen Time APIs and special entitlements, so this button cannot work on iOS.'**
  String get iphoneUsageDescription;

  /// No description provided for @turnOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services'**
  String get turnOnLocation;

  /// No description provided for @locationIsOff.
  ///
  /// In en, this message translates to:
  /// **'Location is off. Enable it to share with parent.'**
  String get locationIsOff;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Location Settings'**
  String get openLocationSettings;

  /// No description provided for @locationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location permission blocked'**
  String get locationBlocked;

  /// No description provided for @enableLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable location access in system settings.'**
  String get enableLocationAccess;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get openAppSettings;

  /// No description provided for @allowLocationToShare.
  ///
  /// In en, this message translates to:
  /// **'Allow location to share'**
  String get allowLocationToShare;

  /// No description provided for @grantLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant permission so your parent can see where you are.'**
  String get grantLocationPermission;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// No description provided for @myChildren.
  ///
  /// In en, this message translates to:
  /// **'My Children'**
  String get myChildren;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChild;

  /// No description provided for @noChildrenYet.
  ///
  /// In en, this message translates to:
  /// **'No children yet. Tap \"Add Child\" to create one.'**
  String get noChildrenYet;

  /// No description provided for @parentAccount.
  ///
  /// In en, this message translates to:
  /// **'Parent account'**
  String get parentAccount;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @deleteChildTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete child?'**
  String get deleteChildTitle;

  /// No description provided for @deleteChildMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {childName} and all linked activity history?'**
  String deleteChildMessage(String childName);

  /// No description provided for @childDeleted.
  ///
  /// In en, this message translates to:
  /// **'{childName} deleted'**
  String childDeleted(String childName);

  /// No description provided for @failedToDeleteChild.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete child: {error}'**
  String failedToDeleteChild(String error);

  /// No description provided for @avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get avatarUpdated;

  /// No description provided for @failedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedGeneric(String error);

  /// No description provided for @createChildAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Child Account'**
  String get createChildAccount;

  /// No description provided for @childSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Your child will sign in with these credentials on their device.'**
  String get childSignInHint;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Display name (e.g. Alex)'**
  String get displayNameHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editChildProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Child Profile'**
  String get editChildProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteChild.
  ///
  /// In en, this message translates to:
  /// **'Delete Child'**
  String get deleteChild;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'PARENT'**
  String get parent;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'CHILD'**
  String get child;

  /// No description provided for @editProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit profile details'**
  String get editProfileDetails;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @manageChildrenMenu.
  ///
  /// In en, this message translates to:
  /// **'Manage Children'**
  String get manageChildrenMenu;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @locationAlerts.
  ///
  /// In en, this message translates to:
  /// **'Location Alerts'**
  String get locationAlerts;

  /// No description provided for @batteryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Battery Alerts'**
  String get batteryAlerts;

  /// No description provided for @safeZoneAlerts.
  ///
  /// In en, this message translates to:
  /// **'Safe Zone Alerts'**
  String get safeZoneAlerts;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to send alerts'**
  String get notificationPermissionRequired;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Kid Security v1.0.0'**
  String get appVersion;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @updateProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Update your display name and username.'**
  String get updateProfileHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @usernameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameCannotBeEmpty;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @failedToUploadAvatar.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload avatar: {error}'**
  String failedToUploadAvatar(String error);

  /// No description provided for @parentProfile.
  ///
  /// In en, this message translates to:
  /// **'Parent Profile'**
  String get parentProfile;

  /// No description provided for @addChildForStats.
  ///
  /// In en, this message translates to:
  /// **'Add a child account first to see live stats.'**
  String get addChildForStats;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'INSIGHTS'**
  String get insights;

  /// No description provided for @childStats.
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s Stats'**
  String childStats(String childName);

  /// No description provided for @deviceStatus.
  ///
  /// In en, this message translates to:
  /// **'Device Status'**
  String get deviceStatus;

  /// No description provided for @batteryPercent.
  ///
  /// In en, this message translates to:
  /// **'{battery}% battery'**
  String batteryPercent(int battery);

  /// No description provided for @batteryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Battery unknown'**
  String get batteryUnknown;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced {time}'**
  String synced(String time);

  /// No description provided for @noDeviceSyncYet.
  ///
  /// In en, this message translates to:
  /// **'No device sync yet'**
  String get noDeviceSyncYet;

  /// No description provided for @usageAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Usage access granted'**
  String get usageAccessGranted;

  /// No description provided for @usageAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Usage access needed'**
  String get usageAccessNeeded;

  /// No description provided for @iosUsageAccessNote.
  ///
  /// In en, this message translates to:
  /// **'This child device is an iPhone. iOS does not provide Android Usage Access, so this app cannot open that permission screen. Real iPhone screen time and app blocking need Apple Screen Time entitlements and a separate native integration.'**
  String get iosUsageAccessNote;

  /// No description provided for @androidUsageAccessNote.
  ///
  /// In en, this message translates to:
  /// **'Open the child app on the phone and allow usage access. After that, screen time, app limits, and the calendar will sync automatically.'**
  String get androidUsageAccessNote;

  /// No description provided for @dailyUsage.
  ///
  /// In en, this message translates to:
  /// **'Daily Usage'**
  String get dailyUsage;

  /// No description provided for @usageOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{total} of {limit} used'**
  String usageOfLimit(String total, String limit);

  /// No description provided for @usageOnDate.
  ///
  /// In en, this message translates to:
  /// **'{total} used on {date}'**
  String usageOnDate(String total, String date);

  /// No description provided for @allLimitsInRange.
  ///
  /// In en, this message translates to:
  /// **'All enabled limits are within range'**
  String get allLimitsInRange;

  /// No description provided for @appLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'{count} app limit exceeded today'**
  String appLimitExceeded(int count);

  /// No description provided for @setAppLimitsHint.
  ///
  /// In en, this message translates to:
  /// **'Set app limits below to turn this into a real goal.'**
  String get setAppLimitsHint;

  /// No description provided for @weeklyUsage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Usage'**
  String get weeklyUsage;

  /// No description provided for @usageCalendar.
  ///
  /// In en, this message translates to:
  /// **'Usage Calendar'**
  String get usageCalendar;

  /// No description provided for @noAppUsageData.
  ///
  /// In en, this message translates to:
  /// **'No app usage data for this day yet.'**
  String get noAppUsageData;

  /// No description provided for @grantUsageAccessHint.
  ///
  /// In en, this message translates to:
  /// **'Grant usage access on the child phone to see real app data and manage limits.'**
  String get grantUsageAccessHint;

  /// No description provided for @iosAppLimitsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This child phone is an iPhone. The current app build does not have Apple Screen Time integration yet, so real per-app usage and direct app limits are unavailable on iOS.'**
  String get iosAppLimitsUnavailable;

  /// No description provided for @enableDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Enable daily limit'**
  String get enableDailyLimit;

  /// No description provided for @dailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit'**
  String get dailyLimit;

  /// No description provided for @saveLimit.
  ///
  /// In en, this message translates to:
  /// **'Save limit'**
  String get saveLimit;

  /// No description provided for @manageAppLimits.
  ///
  /// In en, this message translates to:
  /// **'Manage App Limits'**
  String get manageAppLimits;

  /// No description provided for @appUsedOnDate.
  ///
  /// In en, this message translates to:
  /// **'{appName} used on {date}'**
  String appUsedOnDate(String appName, String date);

  /// No description provided for @limitMinutes.
  ///
  /// In en, this message translates to:
  /// **'Limit {time}'**
  String limitMinutes(String time);

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @usageTodayOverLimit.
  ///
  /// In en, this message translates to:
  /// **'{time} today · over limit'**
  String usageTodayOverLimit(String time);

  /// No description provided for @usageToday.
  ///
  /// In en, this message translates to:
  /// **'{time} today'**
  String usageToday(String time);

  /// No description provided for @limitSavedFor.
  ///
  /// In en, this message translates to:
  /// **'Limit saved for {appName}'**
  String limitSavedFor(String appName);

  /// No description provided for @limitDisabledFor.
  ///
  /// In en, this message translates to:
  /// **'Limit disabled for {appName}'**
  String limitDisabledFor(String appName);

  /// No description provided for @couldNotSaveLimit.
  ///
  /// In en, this message translates to:
  /// **'Could not save limit: {error}'**
  String couldNotSaveLimit(String error);

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'THU'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get sun;

  /// No description provided for @over.
  ///
  /// In en, this message translates to:
  /// **'OVER'**
  String get over;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get onboardingSubtitle;

  /// No description provided for @iAmParent.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Parent'**
  String get iAmParent;

  /// No description provided for @iAmChild.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Child'**
  String get iAmChild;

  /// No description provided for @parentSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get parentSignIn;

  /// No description provided for @parentCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get parentCreateAccount;

  /// No description provided for @parentAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage and protect your family'**
  String get parentAuthSubtitle;

  /// No description provided for @childSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get childSignIn;

  /// No description provided for @childAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Hey there!'**
  String get childAuthTitle;

  /// No description provided for @childAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask your parent for the invite code'**
  String get childAuthSubtitle;

  /// No description provided for @childNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get childNavSettings;

  /// No description provided for @childProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get childProfile;

  /// No description provided for @childSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get childSettingsTitle;

  /// No description provided for @childLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get childLogout;

  /// No description provided for @inviteChild.
  ///
  /// In en, this message translates to:
  /// **'Invite Child'**
  String get inviteChild;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite children and other family members to your circle'**
  String get inviteTitle;

  /// No description provided for @inviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your family members need to install the app and join the circle using the code'**
  String get inviteSubtitle;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code valid for 3 days'**
  String get inviteCodeLabel;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get shareCode;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get getHelp;

  /// No description provided for @generateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Code'**
  String get generateCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'Join my family circle in Kid Security! Use invite code: {code}\n\nhttps://backend21.pythonanywhere.com/invite/{code}'**
  String inviteShareText(String code);

  /// No description provided for @failedToGenerateCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate code: {error}'**
  String failedToGenerateCode(String error);

  /// No description provided for @childRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Family'**
  String get childRegisterTitle;

  /// No description provided for @childRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code from your parent'**
  String get childRegisterSubtitle;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @setupYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get setupYourProfile;

  /// No description provided for @enterYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get enterYourDetails;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @invalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invite code'**
  String get invalidInviteCode;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveCode.
  ///
  /// In en, this message translates to:
  /// **'Have an invite code? Register'**
  String get dontHaveCode;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'az',
        'de',
        'en',
        'es',
        'fr',
        'hy',
        'it',
        'ka',
        'kk',
        'ky',
        'pl',
        'pt',
        'ru',
        'tg',
        'tk',
        'uz'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'az':
      return SAz();
    case 'de':
      return SDe();
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'fr':
      return SFr();
    case 'hy':
      return SHy();
    case 'it':
      return SIt();
    case 'ka':
      return SKa();
    case 'kk':
      return SKk();
    case 'ky':
      return SKy();
    case 'pl':
      return SPl();
    case 'pt':
      return SPt();
    case 'ru':
      return SRu();
    case 'tg':
      return STg();
    case 'tk':
      return STk();
    case 'uz':
      return SUz();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
