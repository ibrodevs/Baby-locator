// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Anmelden oder Elternkonto erstellen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get createParentAccount => 'Elternkonto erstellen';

  @override
  String get childrenSignInHint =>
      'Kinder melden sich mit den Zugangsdaten an, die von ihrem Elternteil erstellt wurden.';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get navMap => 'Karte';

  @override
  String get navActivity => 'Aktivität';

  @override
  String get navChat => 'Chat';

  @override
  String get navStats => 'Statistik';

  @override
  String get navHome => 'Startseite';

  @override
  String get waitingForLocation =>
      'Warte darauf, dass Kinder ihren Standort teilen...';

  @override
  String get addChildToTrack => 'Kind hinzufügen, um die Verfolgung zu starten';

  @override
  String get manageChildren => 'Kinder verwalten';

  @override
  String get loud => 'LAUT';

  @override
  String get around => 'IN DER NÄHE';

  @override
  String get currentLocation => 'AKTUELLER STANDORT';

  @override
  String messageChild(String childName) {
    return 'Nachricht an $childName';
  }

  @override
  String get history => 'Verlauf';

  @override
  String lastUpdated(String time) {
    return 'Zuletzt aktualisiert: $time';
  }

  @override
  String get statusActive => 'AKTIV';

  @override
  String get statusPaused => 'PAUSIERT';

  @override
  String get statusOffline => 'OFFLINE';

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(int minutes) {
    return 'Vor $minutes Min.';
  }

  @override
  String hoursAgo(int hours) {
    return 'Vor $hours Std.';
  }

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get addChildToSeeActivity =>
      'Kind hinzufügen, um Aktivitäten zu sehen';

  @override
  String get activity => 'Aktivität';

  @override
  String get today => 'Heute';

  @override
  String get leftArea => 'Bereich verlassen';

  @override
  String get arrivedAtLocation => 'Am Ort angekommen';

  @override
  String get phoneCharging => 'Telefon wird geladen';

  @override
  String batteryReached(int battery) {
    return 'Akku bei $battery%';
  }

  @override
  String get batteryLow => 'Akku schwach';

  @override
  String batteryDropped(int battery) {
    return 'Akku auf $battery% gesunken';
  }

  @override
  String get currentLocationTitle => 'Aktueller Standort';

  @override
  String get locationShared => 'Standort geteilt';

  @override
  String get batteryStatus => 'Akkustatus';

  @override
  String batteryAt(int battery) {
    return 'Akku bei $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Noch keine Aktivität. Ereignisse werden angezeigt, sobald $childName seinen Standort teilt.';
  }

  @override
  String get safeZones => 'Orte';

  @override
  String get addNew => 'Neu hinzufügen';

  @override
  String get noSafeZonesYet => 'Noch keine Orte';

  @override
  String zone(String zoneName) {
    return 'Ort: $zoneName';
  }

  @override
  String get editZone => 'Ort bearbeiten';

  @override
  String get activeToday => 'HEUTE AKTIV';

  @override
  String get inactiveToday => 'HEUTE INAKTIV';

  @override
  String get disabled => 'DEAKTIVIERT';

  @override
  String get dailySafetyScore => 'Täglicher Sicherheitsscore';

  @override
  String get noLocationUpdatesYet =>
      'Heute noch keine Standortaktualisierungen';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates von $totalUpdates Aktualisierungen waren heute in Sicherzonen';
  }

  @override
  String coverage(int percent) {
    return 'Abdeckung: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Aktueller Ort: $zoneName';
  }

  @override
  String get addSafeZone => 'Neuen Ort hinzufügen';

  @override
  String get editSafeZone => 'Ort bearbeiten';

  @override
  String get deleteZoneTitle => 'Ort löschen?';

  @override
  String get deleteZoneMessage =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get zoneEnabled => 'ORT AKTIV';

  @override
  String get zoneName => 'ORTSNAME';

  @override
  String get zoneNameHint => 'z. B. Zuhause, Schule';

  @override
  String get activeWhen => 'AKTIV WANN';

  @override
  String get always => 'Immer';

  @override
  String get daysOfWeek => 'Wochentage';

  @override
  String get chooseAtLeastOneDay =>
      'Wählen Sie mindestens einen Tag für diesen Zeitplan.';

  @override
  String get radius => 'RADIUS';

  @override
  String get locationMoveMap =>
      'STANDORT (Karte bewegen, um die Mitte festzulegen)';

  @override
  String get moveMapToSetCenter =>
      'Bewegen Sie die Karte, um die Ortsmitte festzulegen';

  @override
  String get createSafeZone => 'Ort erstellen';

  @override
  String get updateSafeZone => 'Ort aktualisieren';

  @override
  String get pleaseEnterZoneName => 'Bitte einen Ortsnamen eingeben';

  @override
  String get chooseAtLeastOneDayError =>
      'Wählen Sie mindestens einen aktiven Tag';

  @override
  String get addChildToChat => 'Kind hinzufügen, um zu chatten';

  @override
  String get noMessagesYet => 'Noch keine Nachrichten. Sagen Sie Hallo!';

  @override
  String get sendMessage => 'Nachricht senden...';

  @override
  String failedToSend(String error) {
    return 'Senden fehlgeschlagen: $error';
  }

  @override
  String helloUser(String name) {
    return 'Hallo, $name!';
  }

  @override
  String get kidMode => 'Kindermodus';

  @override
  String get myLocation => 'Mein Standort';

  @override
  String get waitingForGps => 'Warte auf GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Mit Elternteil geteilt · $time';
  }

  @override
  String get notSharedYet => 'Noch nicht geteilt';

  @override
  String get imSafe => 'Ich bin sicher';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => '\"Ich bin sicher\" an Ihr Elternteil gesendet';

  @override
  String get sosMessage => 'SOS! Ich brauche Hilfe!';

  @override
  String sosLocation(String address) {
    return ' Standort: $address';
  }

  @override
  String get sosSent => 'SOS gesendet — Elternteil wird benachrichtigt';

  @override
  String get allowUsageAccess => 'Nutzungszugriff erlauben';

  @override
  String get usageAccessDescription =>
      'Damit kann das Eltern-Dashboard echte Bildschirmzeit-Daten und App-Limits von diesem Telefon anzeigen.';

  @override
  String get openUsageAccess => 'Nutzungszugriff öffnen';

  @override
  String syncError(String error) {
    return 'Synchronisierungsfehler: $error';
  }

  @override
  String get iphoneLimitation => 'iPhone-Einschränkung';

  @override
  String get iphoneUsageDescription =>
      'Auf dem iPhone gibt es keinen Android-artigen Nutzungszugriffsbildschirm. Echte App-Bildschirmzeit und direktes App-Sperren benötigen Apple Screen Time-APIs und spezielle Berechtigungen, daher funktioniert diese Schaltfläche nicht auf iOS.';

  @override
  String get turnOnLocation => 'Ortungsdienste einschalten';

  @override
  String get locationIsOff =>
      'Standort ist deaktiviert. Aktivieren Sie ihn, um mit dem Elternteil zu teilen.';

  @override
  String get openLocationSettings => 'Standorteinstellungen öffnen';

  @override
  String get locationBlocked => 'Standortberechtigung gesperrt';

  @override
  String get enableLocationAccess =>
      'Standortzugriff in den Systemeinstellungen aktivieren.';

  @override
  String get openAppSettings => 'App-Einstellungen öffnen';

  @override
  String get allowLocationToShare => 'Standort zum Teilen erlauben';

  @override
  String get grantLocationPermission =>
      'Berechtigung erteilen, damit Ihr Elternteil sehen kann, wo Sie sind.';

  @override
  String get allowLocation => 'Standort erlauben';

  @override
  String get myChildren => 'Meine Kinder';

  @override
  String get addChild => 'Kind hinzufügen';

  @override
  String get noChildrenYet =>
      'Noch keine Kinder. Tippen Sie auf \"Kind hinzufügen\", um eines zu erstellen.';

  @override
  String get parentAccount => 'Elternkonto';

  @override
  String get changePhoto => 'Foto ändern';

  @override
  String get deleteChildTitle => 'Kind löschen?';

  @override
  String deleteChildMessage(String childName) {
    return '$childName und den gesamten verknüpften Aktivitätsverlauf löschen?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName gelöscht';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Kind konnte nicht gelöscht werden: $error';
  }

  @override
  String get avatarUpdated => 'Avatar aktualisiert';

  @override
  String failedGeneric(String error) {
    return 'Fehlgeschlagen: $error';
  }

  @override
  String get createChildAccount => 'Kindkonto erstellen';

  @override
  String get childSignInHint =>
      'Ihr Kind meldet sich mit diesen Zugangsdaten auf seinem Gerät an.';

  @override
  String get displayNameHint => 'Anzeigename (z. B. Alex)';

  @override
  String get create => 'Erstellen';

  @override
  String get editChildProfile => 'Kindprofil bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get deleteChild => 'Kind löschen';

  @override
  String get track => 'Verfolgen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get parent => 'ELTERNTEIL';

  @override
  String get child => 'KIND';

  @override
  String get editProfileDetails => 'Profildetails bearbeiten';

  @override
  String get account => 'Konto';

  @override
  String get manageChildrenMenu => 'Kinder verwalten';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get locationAlerts => 'Standortbenachrichtigungen';

  @override
  String get batteryAlerts => 'Akkubenachrichtigungen';

  @override
  String get safeZoneAlerts => 'Ort-Benachrichtigungen';

  @override
  String get notificationPermissionRequired =>
      'Benachrichtigungsberechtigung ist erforderlich, um Benachrichtigungen zu senden';

  @override
  String get general => 'Allgemein';

  @override
  String get language => 'Sprache';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get helpAndSupport => 'Hilfe & Support';

  @override
  String get about => 'Über';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get signOut => 'Abmelden';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Profil bearbeiten';

  @override
  String get updateProfileHint =>
      'Aktualisieren Sie Ihren Anzeigenamen und Benutzernamen.';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get usernameCannotBeEmpty => 'Benutzername darf nicht leer sein';

  @override
  String get profileUpdated => 'Profil aktualisiert';

  @override
  String failedToUploadAvatar(String error) {
    return 'Avatar-Upload fehlgeschlagen: $error';
  }

  @override
  String get parentProfile => 'Elternprofil';

  @override
  String get addChildForStats =>
      'Fügen Sie zuerst ein Kindkonto hinzu, um Live-Statistiken zu sehen.';

  @override
  String get insights => 'EINBLICKE';

  @override
  String childStats(String childName) {
    return 'Statistiken von $childName';
  }

  @override
  String get deviceStatus => 'Gerätestatus';

  @override
  String batteryPercent(int battery) {
    return '$battery% Akku';
  }

  @override
  String get batteryUnknown => 'Akku unbekannt';

  @override
  String synced(String time) {
    return 'Synchronisiert $time';
  }

  @override
  String get noDeviceSyncYet => 'Noch keine Gerätesynchronisierung';

  @override
  String get usageAccessGranted => 'Nutzungszugriff gewährt';

  @override
  String get usageAccessNeeded => 'Nutzungszugriff erforderlich';

  @override
  String get iosUsageAccessNote =>
      'Dieses Kindergerät ist ein iPhone. iOS bietet keinen Android-Nutzungszugriff, daher kann diese App diesen Berechtigungsbildschirm nicht öffnen. Echte iPhone-Bildschirmzeit und App-Sperren benötigen Apple Screen Time-Berechtigungen und eine separate native Integration.';

  @override
  String get androidUsageAccessNote =>
      'Öffnen Sie die Kinder-App auf dem Telefon und erlauben Sie den Nutzungszugriff. Danach werden Bildschirmzeit, App-Limits und der Kalender automatisch synchronisiert.';

  @override
  String get dailyUsage => 'Tägliche Nutzung';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total von $limit genutzt';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total am $date genutzt';
  }

  @override
  String get allLimitsInRange => 'Alle aktivierten Limits sind im Bereich';

  @override
  String appLimitExceeded(int count) {
    return '$count App-Limit heute überschritten';
  }

  @override
  String get setAppLimitsHint =>
      'Legen Sie unten App-Limits fest, um daraus ein echtes Ziel zu machen.';

  @override
  String get weeklyUsage => 'Wöchentliche Nutzung';

  @override
  String get usageCalendar => 'Nutzungskalender';

  @override
  String get noAppUsageData => 'Noch keine App-Nutzungsdaten für diesen Tag.';

  @override
  String get grantUsageAccessHint =>
      'Gewähren Sie Nutzungszugriff auf dem Kindertelefon, um echte App-Daten zu sehen und Limits zu verwalten.';

  @override
  String get iosAppLimitsUnavailable =>
      'Dieses Kindertelefon ist ein iPhone. Die aktuelle App-Version hat noch keine Apple Screen Time-Integration, daher sind echte App-Nutzung und direkte App-Limits auf iOS nicht verfügbar.';

  @override
  String get enableDailyLimit => 'Tageslimit aktivieren';

  @override
  String get dailyLimit => 'Tageslimit';

  @override
  String get saveLimit => 'Limit speichern';

  @override
  String get manageAppLimits => 'App-Limits verwalten';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName am $date genutzt';
  }

  @override
  String limitMinutes(String time) {
    return 'Limit $time';
  }

  @override
  String get noLimit => 'Kein Limit';

  @override
  String usageTodayOverLimit(String time) {
    return '$time heute · Limit überschritten';
  }

  @override
  String usageToday(String time) {
    return '$time heute';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Limit für $appName gespeichert';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Limit für $appName deaktiviert';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Limit konnte nicht gespeichert werden: $error';
  }

  @override
  String get mon => 'MO';

  @override
  String get tue => 'DI';

  @override
  String get wed => 'MI';

  @override
  String get thu => 'DO';

  @override
  String get fri => 'FR';

  @override
  String get sat => 'SA';

  @override
  String get sun => 'SO';

  @override
  String get over => 'ÜBERSCHRITTEN';

  @override
  String get onboardingTitle => 'Willkommen!';

  @override
  String get onboardingSubtitle => 'Wer bist du?';

  @override
  String get iAmParent => 'Ich bin ein Elternteil';

  @override
  String get iAmChild => 'Ich bin ein Kind';

  @override
  String get parentSignIn => 'Anmelden';

  @override
  String get parentCreateAccount => 'Konto erstellen';

  @override
  String get parentAuthSubtitle => 'Verwalte und schütze deine Familie';

  @override
  String get childSignIn => 'Anmelden';

  @override
  String get childAuthTitle => 'Hallo!';

  @override
  String get childAuthSubtitle => 'Frag deine Eltern nach deinen Anmeldedaten';

  @override
  String get childNavSettings => 'Einstellungen';

  @override
  String get childProfile => 'Profil';

  @override
  String get childSettingsTitle => 'Einstellungen';

  @override
  String get childLogout => 'Abmelden';

  @override
  String get inviteChild => 'Kind einladen';

  @override
  String get inviteTitle =>
      'Kinder und andere Familienmitglieder in deinen Kreis einladen';

  @override
  String get inviteSubtitle =>
      'Deine Familienmitglieder müssen die App installieren und dem Kreis mit dem Code beitreten';

  @override
  String get inviteCodeLabel => 'Code gilt für 3 Tage';

  @override
  String get shareCode => 'Code teilen';

  @override
  String get getHelp => 'Hilfe erhalten';

  @override
  String get generateCode => 'Code generieren';

  @override
  String get codeCopied => 'Code in Zwischenablage kopiert';

  @override
  String inviteShareText(String code) {
    return 'Tritt meinem Familienkreis in Family security bei! Verwende den Einladungscode: $code\n\nhttp://89.108.81.151/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Code konnte nicht generiert werden: $error';
  }

  @override
  String get childRegisterTitle => 'Familie beitreten';

  @override
  String get childRegisterSubtitle =>
      'Gib den Einladungscode deines Elternteils ein';

  @override
  String get inviteCode => 'Einladungscode';

  @override
  String get next => 'Weiter';

  @override
  String get setupYourProfile => 'Dein Profil einrichten';

  @override
  String get enterYourDetails => 'Gib deinen Anzeigenamen ein';

  @override
  String get register => 'Registrieren';

  @override
  String get invalidInviteCode => 'Ungültiger oder abgelaufener Einladungscode';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto? Anmelden';

  @override
  String get dontHaveCode => 'Einladungscode? Registrieren';

  @override
  String get placesOnMap => 'Orte auf der Karte';

  @override
  String get placesAndChildren => 'Orte und Kinder';

  @override
  String placesCount(int count) {
    return 'Orte: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Heute aktiv: $count';
  }

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get createPlaceHint =>
      'Erstellen Sie einen Ort, um Benachrichtigungen zu erhalten, wenn Ihr Kind ankommt oder geht.';

  @override
  String get untitledPlace => 'Unbenannter Ort';

  @override
  String get placeDeleted => 'Ort gelöscht.';

  @override
  String get editLabel => 'Bearbeiten';

  @override
  String get disabledSchedule => 'Deaktiviert';

  @override
  String get noDaysSelected => 'Keine Tage ausgewählt';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Radius $radius • $schedule';
  }

  @override
  String get proActive => 'Pro aktiv';

  @override
  String get freePlan => 'Kostenloser Plan';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get skip => 'Überspringen';

  @override
  String get getPremium => 'Premium erhalten';

  @override
  String get monthly => 'Monatlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get bestValue => 'Bestes Angebot';

  @override
  String get perMonth => 'pro Monat';

  @override
  String get perYearSave58 => 'pro Jahr · 58% sparen';

  @override
  String get paywallProductName => 'Family Security Pro';

  @override
  String get paywallUpgrade => 'Upgraden';

  @override
  String paywallBestValueSave(int percent) {
    return 'Bestes Angebot · $percent% sparen';
  }

  @override
  String get paywallBenefitAddChildren =>
      'Mehrere Kinder zu einem Familienkonto hinzufügen';

  @override
  String get paywallBenefitUnlockTools =>
      'Audioüberwachung, Live-Karte, Verlauf, Statistiken und Alarmfunktionen freischalten';

  @override
  String get paywallBenefitFullDashboard =>
      'Das gesamte Eltern-Dashboard ohne Einschränkungen des kostenlosen Plans nutzen';

  @override
  String get paywallBenefitAudio =>
      'Live-Umgebungsaudio in der Nähe des Kindergeräts';

  @override
  String get paywallBenefitAppLimits =>
      'App-Limits, Nutzungsanalysen und Bewegungsverlauf';

  @override
  String get paywallBenefitAlarm =>
      'Lauter Alarm, Erfolge und erweiterte Elternsteuerung';

  @override
  String get paywallIncludedWithPro => 'In Pro enthalten';

  @override
  String get paywallPlansTitle => 'Verfügbare Pläne';

  @override
  String get paywallRecommended => 'Empfohlen';

  @override
  String paywallPerMonthEquivalent(String price) {
    return '$price monatliches Äquivalent';
  }

  @override
  String get paywallChooseYourPlan => 'Wähle deinen Plan';

  @override
  String get paywallChoosePlanDescription =>
      'Wähle den monatlichen oder jährlichen Family Security Pro Plan, der am besten zu deiner Familie passt.';

  @override
  String get paywallLoadingPlans => 'Abonnementpläne werden geladen...';

  @override
  String get paywallNoOffering => 'Derzeit ist kein Angebot verfügbar.';

  @override
  String get paywallPlatformOnly =>
      'Paywalls sind in diesem Build nur auf iOS und Android verfügbar.';

  @override
  String get subscriptionRestored => 'Dein Abonnement wurde wiederhergestellt.';

  @override
  String get noSubscriptionFound =>
      'Kein aktives Abonnement zum Wiederherstellen gefunden.';

  @override
  String get subscriptionNowActive => 'Family Security Pro ist jetzt aktiv.';

  @override
  String get purchaseEntitlementPending =>
      'Kauf abgeschlossen, aber das Abonnement ist noch nicht aktiv.';

  @override
  String get premiumTitleAdditionalChildren =>
      'Mehr Kinderprofile freischalten';

  @override
  String get premiumTitleLiveMap => 'Live-Familienkarte freischalten';

  @override
  String get premiumTitleMovementHistory => 'Bewegungsverlauf freischalten';

  @override
  String get premiumTitleAudioMonitoring =>
      'Live-Umgebungsgeräusche freischalten';

  @override
  String get premiumTitleScreenTime => 'Bildschirmzeitsteuerung freischalten';

  @override
  String get premiumTitleAppStats => 'App-Nutzungsanalyse freischalten';

  @override
  String get premiumTitleAchievements => 'Erfolge und Belohnungen freischalten';

  @override
  String get premiumTitleLoudAlarm =>
      'Ferngesteuerter lauter Alarm freischalten';

  @override
  String get premiumTitleFullMenu => 'Das vollständige Elternmenü freischalten';

  @override
  String get premiumTitleGeneric => 'Family Security Pro freischalten';

  @override
  String get premiumSubtitleAdditionalChildren =>
      'Kostenlose Konten können nur ein Kind verwalten. Upgrade, um die gesamte Familie hinzuzufügen.';

  @override
  String get premiumSubtitleLiveMap =>
      'Sieh Standort, Status und Fernaktionen aller Kinder auf einer Karte.';

  @override
  String get premiumSubtitleMovementHistory =>
      'Historische Routen überprüfen, Bewegungen wiedergeben und Standortänderungen untersuchen.';

  @override
  String get premiumSubtitleAudioMonitoring =>
      'Höre Umgebungsgeräusche in der Nähe des Kindes, wenn du sofortigen Kontext benötigst.';

  @override
  String get premiumSubtitleScreenTime =>
      'Täglich App-Limits setzen, Apps sperren und gesündere Gerätenutzungsgewohnheiten fördern.';

  @override
  String get premiumSubtitleAppStats =>
      'Nutzungsstatistiken, Trends und Verhaltenseinblicke auf App-Ebene anzeigen.';

  @override
  String get premiumSubtitleAchievements =>
      'Nutze Aufgaben, Sterne und Belohnungen, um positive Gewohnheiten für dein Kind zu fördern.';

  @override
  String get premiumSubtitleLoudAlarm =>
      'Löse aus der Ferne einen lauten Alarm aus, um das Kindergerät schnell zu finden.';

  @override
  String get premiumSubtitleFullMenu =>
      'Das erweiterte Elternmenü, Steuerelemente und Überwachungstools sind Teil von Pro.';

  @override
  String get premiumSubtitleGeneric =>
      'Upgrade auf Family Security Pro, um erweiterte Kindersicherungs- und Überwachungstools freizuschalten.';

  @override
  String get seePlans => 'Pläne ansehen';
}
