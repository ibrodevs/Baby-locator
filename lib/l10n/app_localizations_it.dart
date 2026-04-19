// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class SIt extends S {
  SIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Kid Security';

  @override
  String get signInOrCreate => 'Accedi o crea un account genitore';

  @override
  String get signIn => 'Accedi';

  @override
  String get createParentAccount => 'Crea account genitore';

  @override
  String get childrenSignInHint =>
      'I bambini accedono con le credenziali create dal loro genitore.';

  @override
  String get createAccount => 'Crea account';

  @override
  String get displayName => 'Nome visualizzato';

  @override
  String get username => 'Nome utente';

  @override
  String get password => 'Password';

  @override
  String get navMap => 'Mappa';

  @override
  String get navActivity => 'Attività';

  @override
  String get navChat => 'Chat';

  @override
  String get navStats => 'Statistiche';

  @override
  String get navHome => 'Home';

  @override
  String get waitingForLocation =>
      'In attesa che i bambini condividano la posizione...';

  @override
  String get addChildToTrack =>
      'Aggiungi un bambino per iniziare il monitoraggio';

  @override
  String get manageChildren => 'Gestisci bambini';

  @override
  String get loud => 'FORTE';

  @override
  String get around => 'NELLE VICINANZE';

  @override
  String get currentLocation => 'POSIZIONE ATTUALE';

  @override
  String messageChild(String childName) {
    return 'Messaggio a $childName';
  }

  @override
  String get history => 'Cronologia';

  @override
  String lastUpdated(String time) {
    return 'Ultimo aggiornamento: $time';
  }

  @override
  String get statusActive => 'ATTIVO';

  @override
  String get statusPaused => 'IN PAUSA';

  @override
  String get statusOffline => 'OFFLINE';

  @override
  String get justNow => 'Proprio ora';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min fa';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ore fa';
  }

  @override
  String get active => 'Attivo';

  @override
  String get inactive => 'Inattivo';

  @override
  String get addChildToSeeActivity =>
      'Aggiungi un bambino per vedere l\'attività';

  @override
  String get activity => 'Attività';

  @override
  String get today => 'Oggi';

  @override
  String get leftArea => 'Ha lasciato l\'area';

  @override
  String get arrivedAtLocation => 'Arrivato alla destinazione';

  @override
  String get phoneCharging => 'Telefono in carica';

  @override
  String batteryReached(int battery) {
    return 'Batteria al $battery%';
  }

  @override
  String get batteryLow => 'Batteria scarica';

  @override
  String batteryDropped(int battery) {
    return 'Batteria scesa al $battery%';
  }

  @override
  String get currentLocationTitle => 'Posizione attuale';

  @override
  String get locationShared => 'Posizione condivisa';

  @override
  String get batteryStatus => 'Stato della batteria';

  @override
  String batteryAt(int battery) {
    return 'Batteria al $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Nessuna attività ancora. Gli eventi appariranno quando $childName condividerà la propria posizione.';
  }

  @override
  String get safeZones => 'Zone sicure';

  @override
  String get addNew => 'Aggiungi';

  @override
  String get noSafeZonesYet => 'Nessuna zona sicura ancora';

  @override
  String zone(String zoneName) {
    return 'Zona: $zoneName';
  }

  @override
  String get editZone => 'Modifica zona';

  @override
  String get activeToday => 'ATTIVO OGGI';

  @override
  String get inactiveToday => 'INATTIVO OGGI';

  @override
  String get disabled => 'DISABILITATO';

  @override
  String get dailySafetyScore => 'Punteggio di sicurezza giornaliero';

  @override
  String get noLocationUpdatesYet => 'Nessun aggiornamento di posizione oggi';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates su $totalUpdates aggiornamenti erano in zone sicure oggi';
  }

  @override
  String coverage(int percent) {
    return 'Copertura: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Zona attuale: $zoneName';
  }

  @override
  String get addSafeZone => 'Aggiungi zona sicura';

  @override
  String get editSafeZone => 'Modifica zona sicura';

  @override
  String get deleteZoneTitle => 'Eliminare la zona?';

  @override
  String get deleteZoneMessage => 'Questa azione non può essere annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get zoneEnabled => 'ZONA ABILITATA';

  @override
  String get zoneName => 'NOME ZONA';

  @override
  String get zoneNameHint => 'es. Casa, Scuola';

  @override
  String get activeWhen => 'ATTIVO QUANDO';

  @override
  String get always => 'Sempre';

  @override
  String get daysOfWeek => 'Giorni della settimana';

  @override
  String get chooseAtLeastOneDay =>
      'Scegli almeno un giorno per questo programma.';

  @override
  String get radius => 'RAGGIO';

  @override
  String get locationMoveMap =>
      'POSIZIONE (Sposta la mappa per centrare il pin)';

  @override
  String get moveMapToSetCenter =>
      'Sposta la mappa per impostare il centro della zona';

  @override
  String get createSafeZone => 'Crea zona sicura';

  @override
  String get updateSafeZone => 'Aggiorna zona sicura';

  @override
  String get pleaseEnterZoneName => 'Inserisci un nome per la zona';

  @override
  String get chooseAtLeastOneDayError => 'Scegli almeno un giorno attivo';

  @override
  String get addChildToChat => 'Aggiungi un bambino per iniziare a chattare';

  @override
  String get noMessagesYet => 'Nessun messaggio ancora. Di\' ciao!';

  @override
  String get sendMessage => 'Invia un messaggio...';

  @override
  String failedToSend(String error) {
    return 'Invio fallito: $error';
  }

  @override
  String helloUser(String name) {
    return 'Ciao, $name!';
  }

  @override
  String get kidMode => 'Modalità bambino';

  @override
  String get myLocation => 'La mia posizione';

  @override
  String get waitingForGps => 'In attesa del GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Condiviso con il genitore · $time';
  }

  @override
  String get notSharedYet => 'Non ancora condiviso';

  @override
  String get imSafe => 'Sono al sicuro';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => '\"Sono al sicuro\" inviato al tuo genitore';

  @override
  String get sosMessage => 'SOS! Ho bisogno di aiuto!';

  @override
  String sosLocation(String address) {
    return ' Posizione: $address';
  }

  @override
  String get sosSent => 'SOS inviato — il genitore verrà notificato';

  @override
  String get allowUsageAccess => 'Consenti accesso all\'utilizzo';

  @override
  String get usageAccessDescription =>
      'Questo consente alla dashboard del genitore di mostrare i dati reali sul tempo di utilizzo dello schermo e i limiti delle app da questo telefono.';

  @override
  String get openUsageAccess => 'Apri accesso all\'utilizzo';

  @override
  String syncError(String error) {
    return 'Errore di sincronizzazione: $error';
  }

  @override
  String get iphoneLimitation => 'Limitazione iPhone';

  @override
  String get iphoneUsageDescription =>
      'Su iPhone non è presente una schermata di accesso all\'utilizzo come su Android. Il tempo reale di schermo per app e il blocco diretto delle app richiedono le API Screen Time di Apple e autorizzazioni speciali, pertanto questo pulsante non funziona su iOS.';

  @override
  String get turnOnLocation => 'Attiva i servizi di localizzazione';

  @override
  String get locationIsOff =>
      'La posizione è disattivata. Attivala per condividere con il genitore.';

  @override
  String get openLocationSettings => 'Apri impostazioni posizione';

  @override
  String get locationBlocked => 'Autorizzazione posizione bloccata';

  @override
  String get enableLocationAccess =>
      'Abilita l\'accesso alla posizione nelle impostazioni di sistema.';

  @override
  String get openAppSettings => 'Apri impostazioni app';

  @override
  String get allowLocationToShare => 'Consenti posizione per condividere';

  @override
  String get grantLocationPermission =>
      'Concedi il permesso per permettere al tuo genitore di vedere dove ti trovi.';

  @override
  String get allowLocation => 'Consenti posizione';

  @override
  String get myChildren => 'I miei bambini';

  @override
  String get addChild => 'Aggiungi bambino';

  @override
  String get noChildrenYet =>
      'Nessun bambino ancora. Tocca \"Aggiungi bambino\" per crearne uno.';

  @override
  String get parentAccount => 'Account genitore';

  @override
  String get changePhoto => 'Cambia foto';

  @override
  String get deleteChildTitle => 'Eliminare il bambino?';

  @override
  String deleteChildMessage(String childName) {
    return 'Eliminare $childName e tutta la cronologia delle attività collegata?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName eliminato';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Impossibile eliminare il bambino: $error';
  }

  @override
  String get avatarUpdated => 'Avatar aggiornato';

  @override
  String failedGeneric(String error) {
    return 'Fallito: $error';
  }

  @override
  String get createChildAccount => 'Crea account bambino';

  @override
  String get childSignInHint =>
      'Il tuo bambino accederà con queste credenziali sul suo dispositivo.';

  @override
  String get displayNameHint => 'Nome visualizzato (es. Alex)';

  @override
  String get create => 'Crea';

  @override
  String get editChildProfile => 'Modifica profilo bambino';

  @override
  String get save => 'Salva';

  @override
  String get deleteChild => 'Elimina bambino';

  @override
  String get track => 'Monitora';

  @override
  String get edit => 'Modifica';

  @override
  String get settings => 'Impostazioni';

  @override
  String get parent => 'GENITORE';

  @override
  String get child => 'BAMBINO';

  @override
  String get editProfileDetails => 'Modifica dettagli profilo';

  @override
  String get account => 'Account';

  @override
  String get manageChildrenMenu => 'Gestisci bambini';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get notifications => 'Notifiche';

  @override
  String get pushNotifications => 'Notifiche push';

  @override
  String get locationAlerts => 'Avvisi di posizione';

  @override
  String get batteryAlerts => 'Avvisi batteria';

  @override
  String get safeZoneAlerts => 'Avvisi zone sicure';

  @override
  String get notificationPermissionRequired =>
      'L\'autorizzazione per le notifiche è necessaria per inviare avvisi';

  @override
  String get general => 'Generale';

  @override
  String get language => 'Lingua';

  @override
  String get systemDefault => 'Predefinito di sistema';

  @override
  String get helpAndSupport => 'Aiuto e supporto';

  @override
  String get about => 'Informazioni';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get signOut => 'Esci';

  @override
  String get appVersion => 'Kid Security v1.0.0';

  @override
  String get editProfileTitle => 'Modifica profilo';

  @override
  String get updateProfileHint =>
      'Aggiorna il tuo nome visualizzato e il nome utente.';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get usernameCannotBeEmpty => 'Il nome utente non può essere vuoto';

  @override
  String get profileUpdated => 'Profilo aggiornato';

  @override
  String failedToUploadAvatar(String error) {
    return 'Caricamento avatar fallito: $error';
  }

  @override
  String get parentProfile => 'Profilo genitore';

  @override
  String get addChildForStats =>
      'Aggiungi prima un account bambino per vedere le statistiche in tempo reale.';

  @override
  String get insights => 'APPROFONDIMENTI';

  @override
  String childStats(String childName) {
    return 'Statistiche di $childName';
  }

  @override
  String get deviceStatus => 'Stato dispositivo';

  @override
  String batteryPercent(int battery) {
    return '$battery% di batteria';
  }

  @override
  String get batteryUnknown => 'Batteria sconosciuta';

  @override
  String synced(String time) {
    return 'Sincronizzato $time';
  }

  @override
  String get noDeviceSyncYet => 'Nessuna sincronizzazione dispositivo ancora';

  @override
  String get usageAccessGranted => 'Accesso all\'utilizzo concesso';

  @override
  String get usageAccessNeeded => 'Accesso all\'utilizzo necessario';

  @override
  String get iosUsageAccessNote =>
      'Questo dispositivo bambino è un iPhone. iOS non fornisce l\'accesso all\'utilizzo Android, quindi questa app non può aprire quella schermata di autorizzazione. Il tempo di schermo reale dell\'iPhone e il blocco delle app richiedono i permessi Screen Time di Apple e un\'integrazione nativa separata.';

  @override
  String get androidUsageAccessNote =>
      'Apri l\'app bambino sul telefono e consenti l\'accesso all\'utilizzo. Dopodiché, il tempo di schermo, i limiti delle app e il calendario si sincronizzeranno automaticamente.';

  @override
  String get dailyUsage => 'Utilizzo giornaliero';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total su $limit utilizzato';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total utilizzato il $date';
  }

  @override
  String get allLimitsInRange => 'Tutti i limiti abilitati sono nel range';

  @override
  String appLimitExceeded(int count) {
    return '$count limite app superato oggi';
  }

  @override
  String get setAppLimitsHint =>
      'Imposta i limiti delle app qui sotto per trasformarlo in un obiettivo reale.';

  @override
  String get weeklyUsage => 'Utilizzo settimanale';

  @override
  String get usageCalendar => 'Calendario utilizzo';

  @override
  String get noAppUsageData =>
      'Nessun dato sull\'utilizzo delle app per questo giorno ancora.';

  @override
  String get grantUsageAccessHint =>
      'Concedi l\'accesso all\'utilizzo sul telefono del bambino per vedere i dati reali delle app e gestire i limiti.';

  @override
  String get iosAppLimitsUnavailable =>
      'Questo telefono bambino è un iPhone. La versione attuale dell\'app non ha ancora l\'integrazione Apple Screen Time, quindi l\'utilizzo reale per app e i limiti diretti non sono disponibili su iOS.';

  @override
  String get enableDailyLimit => 'Abilita limite giornaliero';

  @override
  String get dailyLimit => 'Limite giornaliero';

  @override
  String get saveLimit => 'Salva limite';

  @override
  String get manageAppLimits => 'Gestisci limiti app';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName utilizzato il $date';
  }

  @override
  String limitMinutes(String time) {
    return 'Limite $time';
  }

  @override
  String get noLimit => 'Nessun limite';

  @override
  String usageTodayOverLimit(String time) {
    return '$time oggi · oltre il limite';
  }

  @override
  String usageToday(String time) {
    return '$time oggi';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Limite salvato per $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Limite disabilitato per $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Impossibile salvare il limite: $error';
  }

  @override
  String get mon => 'LUN';

  @override
  String get tue => 'MAR';

  @override
  String get wed => 'MER';

  @override
  String get thu => 'GIO';

  @override
  String get fri => 'VEN';

  @override
  String get sat => 'SAB';

  @override
  String get sun => 'DOM';

  @override
  String get over => 'SUPERATO';

  @override
  String get onboardingTitle => 'Benvenuto!';

  @override
  String get onboardingSubtitle => 'Chi sei?';

  @override
  String get iAmParent => 'Sono un genitore';

  @override
  String get iAmChild => 'Sono un bambino';

  @override
  String get parentSignIn => 'Accedi';

  @override
  String get parentCreateAccount => 'Crea account';

  @override
  String get parentAuthSubtitle => 'Gestisci e proteggi la tua famiglia';

  @override
  String get childSignIn => 'Accedi';

  @override
  String get childAuthTitle => 'Ciao!';

  @override
  String get childAuthSubtitle => 'Chiedi al tuo genitore i dati di accesso';

  @override
  String get childNavSettings => 'Impostazioni';

  @override
  String get childProfile => 'Profilo';

  @override
  String get childSettingsTitle => 'Impostazioni';

  @override
  String get childLogout => 'Esci';
}
