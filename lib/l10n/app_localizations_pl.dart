// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class SPl extends S {
  SPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Zaloguj się lub utwórz konto rodzica';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get createParentAccount => 'Utwórz konto rodzica';

  @override
  String get childrenSignInHint =>
      'Dzieci logują się danymi utworzonymi przez ich rodzica.';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get displayName => 'Nazwa wyświetlana';

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get password => 'Hasło';

  @override
  String get navMap => 'Mapa';

  @override
  String get navActivity => 'Aktywność';

  @override
  String get navChat => 'Czat';

  @override
  String get navStats => 'Statystyki';

  @override
  String get navHome => 'Strona główna';

  @override
  String get waitingForLocation =>
      'Oczekiwanie na udostępnienie lokalizacji przez dzieci...';

  @override
  String get addChildToTrack => 'Dodaj dziecko, aby rozpocząć śledzenie';

  @override
  String get manageChildren => 'Zarządzaj dziećmi';

  @override
  String get loud => 'GŁOŚNO';

  @override
  String get around => 'W POBLIŻU';

  @override
  String get currentLocation => 'BIEŻĄCA LOKALIZACJA';

  @override
  String messageChild(String childName) {
    return 'Wiadomość do $childName';
  }

  @override
  String get history => 'Historia';

  @override
  String lastUpdated(String time) {
    return 'Ostatnia aktualizacja: $time';
  }

  @override
  String get statusActive => 'AKTYWNY';

  @override
  String get statusPaused => 'WSTRZYMANY';

  @override
  String get statusOffline => 'OFFLINE';

  @override
  String get justNow => 'Przed chwilą';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min temu';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours godz. temu';
  }

  @override
  String get active => 'Aktywny';

  @override
  String get inactive => 'Nieaktywny';

  @override
  String get addChildToSeeActivity => 'Dodaj dziecko, aby zobaczyć aktywność';

  @override
  String get activity => 'Aktywność';

  @override
  String get today => 'Dzisiaj';

  @override
  String get leftArea => 'Opuścił obszar';

  @override
  String get arrivedAtLocation => 'Dotarł do lokalizacji';

  @override
  String get phoneCharging => 'Telefon ładuje się';

  @override
  String batteryReached(int battery) {
    return 'Bateria osiągnęła $battery%';
  }

  @override
  String get batteryLow => 'Niski poziom baterii';

  @override
  String batteryDropped(int battery) {
    return 'Bateria spadła do $battery%';
  }

  @override
  String get currentLocationTitle => 'Bieżąca lokalizacja';

  @override
  String get locationShared => 'Lokalizacja udostępniona';

  @override
  String get batteryStatus => 'Stan baterii';

  @override
  String batteryAt(int battery) {
    return 'Bateria na poziomie $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Brak aktywności. Zdarzenia pojawią się, gdy $childName udostępni swoją lokalizację.';
  }

  @override
  String get safeZones => 'Miejsca';

  @override
  String get addNew => 'Dodaj nową';

  @override
  String get noSafeZonesYet => 'Brak miejsc';

  @override
  String zone(String zoneName) {
    return 'Miejsce: $zoneName';
  }

  @override
  String get editZone => 'Edytuj miejsce';

  @override
  String get activeToday => 'AKTYWNA DZISIAJ';

  @override
  String get inactiveToday => 'NIEAKTYWNA DZISIAJ';

  @override
  String get disabled => 'WYŁĄCZONA';

  @override
  String get dailySafetyScore => 'Dzienny wskaźnik bezpieczeństwa';

  @override
  String get noLocationUpdatesYet => 'Brak aktualizacji lokalizacji dzisiaj';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates z $totalUpdates aktualizacji było dzisiaj w strefach bezpiecznych';
  }

  @override
  String coverage(int percent) {
    return 'Zasięg: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Aktualne miejsce: $zoneName';
  }

  @override
  String get addSafeZone => 'Dodaj nowe miejsce';

  @override
  String get editSafeZone => 'Edytuj miejsce';

  @override
  String get deleteZoneTitle => 'Usunąć miejsce?';

  @override
  String get deleteZoneMessage => 'Tej operacji nie można cofnąć.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get zoneEnabled => 'MIEJSCE AKTYWNE';

  @override
  String get zoneName => 'NAZWA MIEJSCA';

  @override
  String get zoneNameHint => 'np. Dom, Szkoła';

  @override
  String get activeWhen => 'AKTYWNA KIEDY';

  @override
  String get always => 'Zawsze';

  @override
  String get daysOfWeek => 'Dni tygodnia';

  @override
  String get chooseAtLeastOneDay =>
      'Wybierz co najmniej jeden dzień dla tego harmonogramu.';

  @override
  String get radius => 'PROMIEŃ';

  @override
  String get locationMoveMap =>
      'LOKALIZACJA (Przesuń mapę, aby ustawić środek)';

  @override
  String get moveMapToSetCenter => 'Przesuń mapę, aby ustawić środek miejsca';

  @override
  String get createSafeZone => 'Utwórz miejsce';

  @override
  String get updateSafeZone => 'Zaktualizuj miejsce';

  @override
  String get pleaseEnterZoneName => 'Wpisz nazwę miejsca';

  @override
  String get chooseAtLeastOneDayError =>
      'Wybierz co najmniej jeden aktywny dzień';

  @override
  String get addChildToChat => 'Dodaj dziecko, aby rozpocząć czat';

  @override
  String get noMessagesYet => 'Brak wiadomości. Napisz coś!';

  @override
  String get sendMessage => 'Napisz wiadomość...';

  @override
  String failedToSend(String error) {
    return 'Nie udało się wysłać: $error';
  }

  @override
  String helloUser(String name) {
    return 'Cześć, $name!';
  }

  @override
  String get kidMode => 'Tryb dziecka';

  @override
  String get myLocation => 'Moja lokalizacja';

  @override
  String get waitingForGps => 'Oczekiwanie na GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Udostępniono rodzicowi · $time';
  }

  @override
  String get notSharedYet => 'Jeszcze nie udostępniono';

  @override
  String get imSafe => 'Jestem bezpieczny';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Wysłano \"Jestem bezpieczny\" do rodzica';

  @override
  String get sosMessage => 'SOS! Potrzebuję pomocy!';

  @override
  String sosLocation(String address) {
    return ' Lokalizacja: $address';
  }

  @override
  String get sosSent => 'SOS wysłany — rodzic zostanie powiadomiony';

  @override
  String get allowUsageAccess => 'Zezwól na dostęp do użycia aplikacji';

  @override
  String get usageAccessDescription =>
      'Umożliwia to panelowi rodzica wyświetlanie rzeczywistych danych dotyczących czasu ekranu i limitów aplikacji z tego telefonu.';

  @override
  String get openUsageAccess => 'Otwórz dostęp do użycia';

  @override
  String syncError(String error) {
    return 'Błąd synchronizacji: $error';
  }

  @override
  String get iphoneLimitation => 'Ograniczenie iPhone';

  @override
  String get iphoneUsageDescription =>
      'Na iPhonie nie ma ekranu dostępu do użycia w stylu Androida. Rzeczywisty czas ekranu per aplikacja i bezpośrednie blokowanie aplikacji wymagają interfejsów API Screen Time Apple i specjalnych uprawnień, więc ten przycisk nie działa na iOS.';

  @override
  String get turnOnLocation => 'Włącz usługi lokalizacji';

  @override
  String get locationIsOff =>
      'Lokalizacja jest wyłączona. Włącz ją, aby udostępnić rodzicowi.';

  @override
  String get openLocationSettings => 'Otwórz ustawienia lokalizacji';

  @override
  String get locationBlocked => 'Uprawnienie do lokalizacji zablokowane';

  @override
  String get enableLocationAccess =>
      'Włącz dostęp do lokalizacji w ustawieniach systemowych.';

  @override
  String get openAppSettings => 'Otwórz ustawienia aplikacji';

  @override
  String get allowLocationToShare => 'Zezwól na lokalizację, aby udostępniać';

  @override
  String get grantLocationPermission =>
      'Przyznaj uprawnienie, aby rodzic mógł zobaczyć, gdzie jesteś.';

  @override
  String get allowLocation => 'Zezwól na lokalizację';

  @override
  String get myChildren => 'Moje dzieci';

  @override
  String get addChild => 'Dodaj dziecko';

  @override
  String get noChildrenYet =>
      'Brak dzieci. Naciśnij \"Dodaj dziecko\", aby je dodać.';

  @override
  String get parentAccount => 'Konto rodzica';

  @override
  String get changePhoto => 'Zmień zdjęcie';

  @override
  String get deleteChildTitle => 'Usunąć dziecko?';

  @override
  String deleteChildMessage(String childName) {
    return 'Usunąć $childName i całą powiązaną historię aktywności?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName usunięty';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Nie udało się usunąć dziecka: $error';
  }

  @override
  String get avatarUpdated => 'Awatar zaktualizowany';

  @override
  String failedGeneric(String error) {
    return 'Błąd: $error';
  }

  @override
  String get createChildAccount => 'Utwórz konto dziecka';

  @override
  String get childSignInHint =>
      'Twoje dziecko zaloguje się tymi danymi na swoim urządzeniu.';

  @override
  String get displayNameHint => 'Nazwa wyświetlana (np. Kasia)';

  @override
  String get create => 'Utwórz';

  @override
  String get editChildProfile => 'Edytuj profil dziecka';

  @override
  String get save => 'Zapisz';

  @override
  String get deleteChild => 'Usuń dziecko';

  @override
  String get track => 'Śledź';

  @override
  String get edit => 'Edytuj';

  @override
  String get settings => 'Ustawienia';

  @override
  String get parent => 'RODZIC';

  @override
  String get child => 'DZIECKO';

  @override
  String get editProfileDetails => 'Edytuj szczegóły profilu';

  @override
  String get account => 'Konto';

  @override
  String get manageChildrenMenu => 'Zarządzaj dziećmi';

  @override
  String get editProfile => 'Edytuj profil';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get pushNotifications => 'Powiadomienia push';

  @override
  String get locationAlerts => 'Alerty lokalizacji';

  @override
  String get batteryAlerts => 'Alerty baterii';

  @override
  String get safeZoneAlerts => 'Alerty miejsc';

  @override
  String get notificationPermissionRequired =>
      'Uprawnienie do powiadomień jest wymagane do wysyłania alertów';

  @override
  String get general => 'Ogólne';

  @override
  String get language => 'Język';

  @override
  String get systemDefault => 'Domyślne ustawienie systemu';

  @override
  String get helpAndSupport => 'Pomoc i wsparcie';

  @override
  String get about => 'O aplikacji';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Edytuj profil';

  @override
  String get updateProfileHint =>
      'Zaktualizuj swoją nazwę wyświetlaną i nazwę użytkownika.';

  @override
  String get saveChanges => 'Zapisz zmiany';

  @override
  String get usernameCannotBeEmpty => 'Nazwa użytkownika nie może być pusta';

  @override
  String get profileUpdated => 'Profil zaktualizowany';

  @override
  String failedToUploadAvatar(String error) {
    return 'Nie udało się przesłać awatara: $error';
  }

  @override
  String get parentProfile => 'Profil rodzica';

  @override
  String get addChildForStats =>
      'Najpierw dodaj konto dziecka, aby zobaczyć statystyki na żywo.';

  @override
  String get insights => 'ANALIZY';

  @override
  String childStats(String childName) {
    return 'Statystyki $childName';
  }

  @override
  String get deviceStatus => 'Stan urządzenia';

  @override
  String batteryPercent(int battery) {
    return '$battery% baterii';
  }

  @override
  String get batteryUnknown => 'Bateria nieznana';

  @override
  String synced(String time) {
    return 'Zsynchronizowano $time';
  }

  @override
  String get noDeviceSyncYet => 'Brak synchronizacji urządzenia';

  @override
  String get usageAccessGranted => 'Dostęp do użycia przyznany';

  @override
  String get usageAccessNeeded => 'Wymagany dostęp do użycia';

  @override
  String get iosUsageAccessNote =>
      'To urządzenie dziecka to iPhone. iOS nie udostępnia dostępu do użycia w stylu Androida, dlatego ta aplikacja nie może otworzyć tego ekranu uprawnień. Rzeczywisty czas ekranu iPhone i blokowanie aplikacji wymagają uprawnień Screen Time Apple i oddzielnej integracji natywnej.';

  @override
  String get androidUsageAccessNote =>
      'Otwórz aplikację dziecka na telefonie i zezwól na dostęp do użycia. Następnie czas ekranu, limity aplikacji i kalendarz będą synchronizowane automatycznie.';

  @override
  String get dailyUsage => 'Dzienne użycie';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total z $limit użyte';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total użyte $date';
  }

  @override
  String get allLimitsInRange => 'Wszystkie włączone limity są w normie';

  @override
  String appLimitExceeded(int count) {
    return '$count limit aplikacji przekroczony dzisiaj';
  }

  @override
  String get setAppLimitsHint =>
      'Ustaw limity aplikacji poniżej, aby zamienić to w realny cel.';

  @override
  String get weeklyUsage => 'Tygodniowe użycie';

  @override
  String get usageCalendar => 'Kalendarz użycia';

  @override
  String get noAppUsageData => 'Brak danych użycia aplikacji na ten dzień.';

  @override
  String get grantUsageAccessHint =>
      'Przyznaj dostęp do użycia na telefonie dziecka, aby zobaczyć rzeczywiste dane aplikacji i zarządzać limitami.';

  @override
  String get iosAppLimitsUnavailable =>
      'Ten telefon to iPhone. Bieżąca wersja aplikacji nie obsługuje jeszcze integracji z Apple Screen Time, dlatego użycie per aplikacja i bezpośrednie limity są niedostępne na iOS.';

  @override
  String get enableDailyLimit => 'Włącz dzienny limit';

  @override
  String get dailyLimit => 'Dzienny limit';

  @override
  String get saveLimit => 'Zapisz limit';

  @override
  String get manageAppLimits => 'Zarządzaj limitami aplikacji';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName użyte $date';
  }

  @override
  String limitMinutes(String time) {
    return 'Limit $time';
  }

  @override
  String get noLimit => 'Brak limitu';

  @override
  String usageTodayOverLimit(String time) {
    return '$time dzisiaj · powyżej limitu';
  }

  @override
  String usageToday(String time) {
    return '$time dzisiaj';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Limit zapisany dla $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Limit wyłączony dla $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Nie udało się zapisać limitu: $error';
  }

  @override
  String get mon => 'PON';

  @override
  String get tue => 'WT';

  @override
  String get wed => 'ŚR';

  @override
  String get thu => 'CZW';

  @override
  String get fri => 'PT';

  @override
  String get sat => 'SOB';

  @override
  String get sun => 'NIE';

  @override
  String get over => 'PRZEKR.';

  @override
  String get onboardingTitle => 'Witamy!';

  @override
  String get onboardingSubtitle => 'Kim jesteś?';

  @override
  String get iAmParent => 'Jestem rodzicem';

  @override
  String get iAmChild => 'Jestem dzieckiem';

  @override
  String get parentSignIn => 'Zaloguj się';

  @override
  String get parentCreateAccount => 'Utwórz konto';

  @override
  String get parentAuthSubtitle => 'Zarządzaj i chroń swoją rodzinę';

  @override
  String get childSignIn => 'Zaloguj się';

  @override
  String get childAuthTitle => 'Cześć!';

  @override
  String get childAuthSubtitle => 'Poproś rodzica o dane logowania';

  @override
  String get childNavSettings => 'Ustawienia';

  @override
  String get childProfile => 'Profil';

  @override
  String get childSettingsTitle => 'Ustawienia';

  @override
  String get childLogout => 'Wyloguj się';

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
  String get placesOnMap => 'Miejsca na mapie';

  @override
  String get placesAndChildren => 'Miejsca i dzieci';

  @override
  String placesCount(int count) {
    return 'Miejsca: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Aktywne dziś: $count';
  }

  @override
  String get retry => 'Ponów';

  @override
  String get createPlaceHint =>
      'Utwórz miejsce, aby otrzymywać powiadomienia, gdy dziecko przychodzi lub wychodzi.';

  @override
  String get untitledPlace => 'Miejsce bez nazwy';

  @override
  String get placeDeleted => 'Miejsce usunięte.';

  @override
  String get editLabel => 'Edytuj';

  @override
  String get disabledSchedule => 'Wyłączone';

  @override
  String get noDaysSelected => 'Nie wybrano dni';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Promień $radius • $schedule';
  }
}
