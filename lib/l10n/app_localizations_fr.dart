// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Se connecter ou créer un compte parent';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createParentAccount => 'Créer un compte parent';

  @override
  String get childrenSignInHint =>
      'Les enfants se connectent avec les identifiants créés par leur parent.';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get navMap => 'Carte';

  @override
  String get navActivity => 'Activité';

  @override
  String get navChat => 'Chat';

  @override
  String get navStats => 'Stats';

  @override
  String get navHome => 'Accueil';

  @override
  String get waitingForLocation =>
      'En attente que les enfants partagent leur position...';

  @override
  String get addChildToTrack => 'Ajoutez un enfant pour commencer le suivi';

  @override
  String get manageChildren => 'Gérer les enfants';

  @override
  String get loud => 'FORT';

  @override
  String get around => 'AUTOUR';

  @override
  String get currentLocation => 'POSITION ACTUELLE';

  @override
  String messageChild(String childName) {
    return 'Message à $childName';
  }

  @override
  String get history => 'Historique';

  @override
  String lastUpdated(String time) {
    return 'Dernière mise à jour : $time';
  }

  @override
  String get statusActive => 'ACTIF';

  @override
  String get statusPaused => 'EN PAUSE';

  @override
  String get statusOffline => 'HORS LIGNE';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get addChildToSeeActivity => 'Ajoutez un enfant pour voir l\'activité';

  @override
  String get activity => 'Activité';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get leftArea => 'A quitté la zone';

  @override
  String get arrivedAtLocation => 'Arrivé à destination';

  @override
  String get phoneCharging => 'Téléphone en charge';

  @override
  String batteryReached(int battery) {
    return 'Batterie à $battery%';
  }

  @override
  String get batteryLow => 'Batterie faible';

  @override
  String batteryDropped(int battery) {
    return 'Batterie tombée à $battery%';
  }

  @override
  String get currentLocationTitle => 'Position actuelle';

  @override
  String get locationShared => 'Position partagée';

  @override
  String get batteryStatus => 'État de la batterie';

  @override
  String batteryAt(int battery) {
    return 'Batterie à $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Aucune activité pour l\'instant. Les événements apparaîtront dès que $childName partagera sa position.';
  }

  @override
  String get safeZones => 'Lieux';

  @override
  String get addNew => 'Ajouter';

  @override
  String get noSafeZonesYet => 'Aucun lieu pour le moment';

  @override
  String zone(String zoneName) {
    return 'Lieu : $zoneName';
  }

  @override
  String get editZone => 'Modifier le lieu';

  @override
  String get activeToday => 'ACTIF AUJOURD\'HUI';

  @override
  String get inactiveToday => 'INACTIF AUJOURD\'HUI';

  @override
  String get disabled => 'DÉSACTIVÉ';

  @override
  String get dailySafetyScore => 'Score de sécurité quotidien';

  @override
  String get noLocationUpdatesYet =>
      'Aucune mise à jour de position aujourd\'hui';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates sur $totalUpdates mises à jour étaient dans des zones sécurisées aujourd\'hui';
  }

  @override
  String coverage(int percent) {
    return 'Couverture : $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Lieu actuel : $zoneName';
  }

  @override
  String get addSafeZone => 'Ajouter un nouveau lieu';

  @override
  String get editSafeZone => 'Modifier le lieu';

  @override
  String get deleteZoneTitle => 'Supprimer le lieu ?';

  @override
  String get deleteZoneMessage => 'Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get zoneEnabled => 'LIEU ACTIF';

  @override
  String get zoneName => 'NOM DU LIEU';

  @override
  String get zoneNameHint => 'ex. Maison, École';

  @override
  String get activeWhen => 'ACTIF QUAND';

  @override
  String get always => 'Toujours';

  @override
  String get daysOfWeek => 'Jours de la semaine';

  @override
  String get chooseAtLeastOneDay =>
      'Choisissez au moins un jour pour ce planning.';

  @override
  String get radius => 'RAYON';

  @override
  String get locationMoveMap =>
      'EMPLACEMENT (Déplacez la carte pour définir le centre)';

  @override
  String get moveMapToSetCenter =>
      'Déplacez la carte pour définir le centre du lieu';

  @override
  String get createSafeZone => 'Créer un lieu';

  @override
  String get updateSafeZone => 'Mettre à jour le lieu';

  @override
  String get pleaseEnterZoneName => 'Veuillez saisir un nom de lieu';

  @override
  String get chooseAtLeastOneDayError => 'Choisissez au moins un jour actif';

  @override
  String get addChildToChat => 'Ajoutez un enfant pour commencer à discuter';

  @override
  String get noMessagesYet => 'Aucun message pour l\'instant. Dites bonjour !';

  @override
  String get sendMessage => 'Envoyer un message...';

  @override
  String failedToSend(String error) {
    return 'Échec de l\'envoi : $error';
  }

  @override
  String helloUser(String name) {
    return 'Bonjour, $name !';
  }

  @override
  String get kidMode => 'Mode enfant';

  @override
  String get myLocation => 'Ma position';

  @override
  String get waitingForGps => 'En attente du GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Partagé avec le parent · $time';
  }

  @override
  String get notSharedYet => 'Pas encore partagé';

  @override
  String get imSafe => 'Je suis en sécurité';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => '\"Je suis en sécurité\" envoyé à votre parent';

  @override
  String get sosMessage => 'SOS ! J\'ai besoin d\'aide !';

  @override
  String sosLocation(String address) {
    return ' Position : $address';
  }

  @override
  String get sosSent => 'SOS envoyé — le parent sera notifié';

  @override
  String get allowUsageAccess => 'Autoriser l\'accès à l\'utilisation';

  @override
  String get usageAccessDescription =>
      'Cela permet au tableau de bord parent d\'afficher les données réelles de temps d\'écran et les limites d\'applications de ce téléphone.';

  @override
  String get openUsageAccess => 'Ouvrir l\'accès à l\'utilisation';

  @override
  String syncError(String error) {
    return 'Erreur de synchronisation : $error';
  }

  @override
  String get iphoneLimitation => 'Limitation iPhone';

  @override
  String get iphoneUsageDescription =>
      'Sur iPhone, il n\'y a pas d\'écran d\'accès à l\'utilisation comme sur Android. Le temps d\'écran réel par application et le blocage direct d\'applications nécessitent les API Screen Time d\'Apple et des droits spéciaux, donc ce bouton ne peut pas fonctionner sur iOS.';

  @override
  String get turnOnLocation => 'Activer les services de localisation';

  @override
  String get locationIsOff =>
      'La localisation est désactivée. Activez-la pour partager avec le parent.';

  @override
  String get openLocationSettings => 'Ouvrir les paramètres de localisation';

  @override
  String get locationBlocked => 'Permission de localisation bloquée';

  @override
  String get enableLocationAccess =>
      'Activez l\'accès à la localisation dans les paramètres système.';

  @override
  String get openAppSettings => 'Ouvrir les paramètres de l\'application';

  @override
  String get allowLocationToShare => 'Autoriser la localisation pour partager';

  @override
  String get grantLocationPermission =>
      'Accordez la permission pour que votre parent puisse voir où vous êtes.';

  @override
  String get allowLocation => 'Autoriser la localisation';

  @override
  String get myChildren => 'Mes enfants';

  @override
  String get addChild => 'Ajouter un enfant';

  @override
  String get noChildrenYet =>
      'Aucun enfant pour l\'instant. Appuyez sur \"Ajouter un enfant\" pour en créer un.';

  @override
  String get parentAccount => 'Compte parent';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get deleteChildTitle => 'Supprimer l\'enfant ?';

  @override
  String deleteChildMessage(String childName) {
    return 'Supprimer $childName et tout l\'historique d\'activité associé ?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName supprimé';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Échec de la suppression de l\'enfant : $error';
  }

  @override
  String get avatarUpdated => 'Avatar mis à jour';

  @override
  String failedGeneric(String error) {
    return 'Échec : $error';
  }

  @override
  String get createChildAccount => 'Créer un compte enfant';

  @override
  String get childSignInHint =>
      'Votre enfant se connectera avec ces identifiants sur son appareil.';

  @override
  String get displayNameHint => 'Nom d\'affichage (ex. Alex)';

  @override
  String get create => 'Créer';

  @override
  String get editChildProfile => 'Modifier le profil de l\'enfant';

  @override
  String get save => 'Enregistrer';

  @override
  String get deleteChild => 'Supprimer l\'enfant';

  @override
  String get track => 'Suivre';

  @override
  String get edit => 'Modifier';

  @override
  String get settings => 'Paramètres';

  @override
  String get parent => 'PARENT';

  @override
  String get child => 'ENFANT';

  @override
  String get editProfileDetails => 'Modifier les détails du profil';

  @override
  String get account => 'Compte';

  @override
  String get manageChildrenMenu => 'Gérer les enfants';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get locationAlerts => 'Alertes de localisation';

  @override
  String get batteryAlerts => 'Alertes de batterie';

  @override
  String get safeZoneAlerts => 'Alertes de lieux';

  @override
  String get notificationPermissionRequired =>
      'L\'autorisation de notification est requise pour envoyer des alertes';

  @override
  String get general => 'Général';

  @override
  String get language => 'Langue';

  @override
  String get systemDefault => 'Langue du système';

  @override
  String get helpAndSupport => 'Aide et assistance';

  @override
  String get about => 'À propos';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get updateProfileHint =>
      'Mettez à jour votre nom d\'affichage et votre nom d\'utilisateur.';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get usernameCannotBeEmpty =>
      'Le nom d\'utilisateur ne peut pas être vide';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String failedToUploadAvatar(String error) {
    return 'Échec du téléversement de l\'avatar : $error';
  }

  @override
  String get parentProfile => 'Profil parent';

  @override
  String get addChildForStats =>
      'Ajoutez d\'abord un compte enfant pour voir les statistiques en direct.';

  @override
  String get insights => 'INFORMATIONS';

  @override
  String childStats(String childName) {
    return 'Statistiques de $childName';
  }

  @override
  String get deviceStatus => 'État de l\'appareil';

  @override
  String batteryPercent(int battery) {
    return '$battery% de batterie';
  }

  @override
  String get batteryUnknown => 'Batterie inconnue';

  @override
  String synced(String time) {
    return 'Synchronisé $time';
  }

  @override
  String get noDeviceSyncYet =>
      'Aucune synchronisation d\'appareil pour l\'instant';

  @override
  String get usageAccessGranted => 'Accès à l\'utilisation accordé';

  @override
  String get usageAccessNeeded => 'Accès à l\'utilisation requis';

  @override
  String get iosUsageAccessNote =>
      'Cet appareil enfant est un iPhone. iOS ne fournit pas d\'accès à l\'utilisation Android, donc cette application ne peut pas ouvrir cet écran de permission. Le temps d\'écran réel et le blocage d\'applications sur iPhone nécessitent les droits Screen Time d\'Apple et une intégration native séparée.';

  @override
  String get androidUsageAccessNote =>
      'Ouvrez l\'application enfant sur le téléphone et autorisez l\'accès à l\'utilisation. Ensuite, le temps d\'écran, les limites d\'applications et le calendrier se synchroniseront automatiquement.';

  @override
  String get dailyUsage => 'Utilisation quotidienne';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total sur $limit utilisé';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total utilisé le $date';
  }

  @override
  String get allLimitsInRange =>
      'Toutes les limites activées sont dans la plage';

  @override
  String appLimitExceeded(int count) {
    return '$count limite d\'application dépassée aujourd\'hui';
  }

  @override
  String get setAppLimitsHint =>
      'Définissez des limites d\'applications ci-dessous pour en faire un vrai objectif.';

  @override
  String get weeklyUsage => 'Utilisation hebdomadaire';

  @override
  String get usageCalendar => 'Calendrier d\'utilisation';

  @override
  String get noAppUsageData =>
      'Aucune donnée d\'utilisation d\'application pour ce jour.';

  @override
  String get grantUsageAccessHint =>
      'Accordez l\'accès à l\'utilisation sur le téléphone de l\'enfant pour voir les données réelles des applications et gérer les limites.';

  @override
  String get iosAppLimitsUnavailable =>
      'Ce téléphone enfant est un iPhone. La version actuelle de l\'application n\'a pas encore l\'intégration Apple Screen Time, donc l\'utilisation réelle par application et les limites directes ne sont pas disponibles sur iOS.';

  @override
  String get enableDailyLimit => 'Activer la limite quotidienne';

  @override
  String get dailyLimit => 'Limite quotidienne';

  @override
  String get saveLimit => 'Enregistrer la limite';

  @override
  String get manageAppLimits => 'Gérer les limites d\'applications';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName utilisé le $date';
  }

  @override
  String limitMinutes(String time) {
    return 'Limite $time';
  }

  @override
  String get noLimit => 'Aucune limite';

  @override
  String usageTodayOverLimit(String time) {
    return '$time aujourd\'hui · dépassement de limite';
  }

  @override
  String usageToday(String time) {
    return '$time aujourd\'hui';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Limite enregistrée pour $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Limite désactivée pour $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Impossible d\'enregistrer la limite : $error';
  }

  @override
  String get mon => 'LUN';

  @override
  String get tue => 'MAR';

  @override
  String get wed => 'MER';

  @override
  String get thu => 'JEU';

  @override
  String get fri => 'VEN';

  @override
  String get sat => 'SAM';

  @override
  String get sun => 'DIM';

  @override
  String get over => 'DÉPASSÉ';

  @override
  String get onboardingTitle => 'Bienvenue !';

  @override
  String get onboardingSubtitle => 'Qui es-tu ?';

  @override
  String get iAmParent => 'Je suis un parent';

  @override
  String get iAmChild => 'Je suis un enfant';

  @override
  String get parentSignIn => 'Se connecter';

  @override
  String get parentCreateAccount => 'Créer un compte';

  @override
  String get parentAuthSubtitle => 'Gérez et protégez votre famille';

  @override
  String get childSignIn => 'Se connecter';

  @override
  String get childAuthTitle => 'Salut !';

  @override
  String get childAuthSubtitle =>
      'Demande à ton parent tes identifiants de connexion';

  @override
  String get childNavSettings => 'Paramètres';

  @override
  String get childProfile => 'Profil';

  @override
  String get childSettingsTitle => 'Paramètres';

  @override
  String get childLogout => 'Se déconnecter';

  @override
  String get inviteChild => 'Inviter un enfant';

  @override
  String get inviteTitle =>
      'Invitez vos enfants et autres membres de la famille dans votre cercle';

  @override
  String get inviteSubtitle =>
      'Vos proches doivent installer l\'application et rejoindre le cercle en utilisant le code';

  @override
  String get inviteCodeLabel => 'Code valable 3 jours';

  @override
  String get shareCode => 'Partager le code';

  @override
  String get getHelp => 'Obtenir de l\'aide';

  @override
  String get generateCode => 'Générer le code';

  @override
  String get codeCopied => 'Code copié dans le presse-papier';

  @override
  String inviteShareText(String code) {
    return 'Rejoignez mon cercle familial dans Family security! Utilisez le code d\'invitation: $code\n\nhttps://baby-locator.online/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Échec de la génération du code: $error';
  }

  @override
  String get childRegisterTitle => 'Rejoindre la famille';

  @override
  String get childRegisterSubtitle =>
      'Entrez le code d\'invitation de votre parent';

  @override
  String get inviteCode => 'Code d\'invitation';

  @override
  String get next => 'Suivant';

  @override
  String get setupYourProfile => 'Configurer votre profil';

  @override
  String get enterYourDetails => 'Entrez votre nom d\'affichage';

  @override
  String get register => 'S\'inscrire';

  @override
  String get invalidInviteCode => 'Code d\'invitation invalide ou expiré';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte? Se connecter';

  @override
  String get dontHaveCode => 'Vous avez un code d\'invitation? S\'inscrire';

  @override
  String get placesOnMap => 'Lieux sur la carte';

  @override
  String get placesAndChildren => 'Lieux et enfants';

  @override
  String placesCount(int count) {
    return 'Lieux : $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Actifs aujourd\'hui : $count';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get createPlaceHint =>
      'Créez un lieu pour recevoir des notifications lorsque votre enfant arrive ou part.';

  @override
  String get untitledPlace => 'Lieu sans nom';

  @override
  String get placeDeleted => 'Lieu supprimé.';

  @override
  String get editLabel => 'Modifier';

  @override
  String get disabledSchedule => 'Désactivé';

  @override
  String get noDaysSelected => 'Aucun jour sélectionné';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Rayon $radius • $schedule';
  }

  @override
  String get proActive => 'Pro actif';

  @override
  String get freePlan => 'Plan gratuit';

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get skip => 'Ignorer';

  @override
  String get getPremium => 'Obtenir Premium';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get bestValue => 'Meilleure offre';

  @override
  String get perMonth => 'par mois';

  @override
  String get perYearSave58 => 'par an · Économisez 58%';

  @override
  String get paywallProductName => 'Family Security Pro';

  @override
  String get paywallUpgrade => 'Mettre à niveau';

  @override
  String paywallBestValueSave(int percent) {
    return 'Meilleure offre · Économisez $percent%';
  }

  @override
  String get paywallBenefitAddChildren =>
      'Ajouter plusieurs enfants à un compte familial';

  @override
  String get paywallBenefitUnlockTools =>
      'Débloquer la surveillance audio, la carte en direct, l\'historique, les statistiques et les alarmes';

  @override
  String get paywallBenefitFullDashboard =>
      'Garder l\'intégralité du tableau de bord parent sans les limites du plan gratuit';

  @override
  String get paywallBenefitAudio =>
      'Audio ambiant en direct près de l\'appareil de l\'enfant';

  @override
  String get paywallBenefitAppLimits =>
      'Limites d\'application, analyses d\'utilisation et historique des déplacements';

  @override
  String get paywallBenefitAlarm =>
      'Alarme sonore, succès et contrôles parentaux avancés';

  @override
  String get paywallIncludedWithPro => 'Inclus avec Pro';

  @override
  String get paywallPlansTitle => 'Plans disponibles';

  @override
  String get paywallRecommended => 'Recommandé';

  @override
  String paywallPerMonthEquivalent(String price) {
    return '$price équivalent mensuel';
  }

  @override
  String get paywallChooseYourPlan => 'Choisissez votre plan';

  @override
  String get paywallChoosePlanDescription =>
      'Choisissez le plan mensuel ou annuel Family Security Pro qui convient le mieux à votre famille.';

  @override
  String get paywallLoadingPlans => 'Chargement des plans d\'abonnement...';

  @override
  String get paywallNoOffering =>
      'Aucune offre n\'est disponible pour le moment.';

  @override
  String get paywallPlatformOnly =>
      'Les murs payants sont disponibles uniquement sur iOS et Android dans cette version.';

  @override
  String get subscriptionRestored => 'Votre abonnement a été restauré.';

  @override
  String get noSubscriptionFound =>
      'Aucun abonnement actif trouvé pour restaurer.';

  @override
  String get subscriptionNowActive =>
      'Family Security Pro est maintenant actif.';

  @override
  String get purchaseEntitlementPending =>
      'Achat terminé, mais l\'abonnement n\'est pas encore actif.';

  @override
  String get premiumTitleAdditionalChildren =>
      'Débloquer plus de profils d\'enfants';

  @override
  String get premiumTitleLiveMap => 'Débloquer la carte familiale en direct';

  @override
  String get premiumTitleMovementHistory =>
      'Débloquer l\'historique des déplacements';

  @override
  String get premiumTitleAudioMonitoring =>
      'Débloquer le son ambiant en direct';

  @override
  String get premiumTitleScreenTime =>
      'Débloquer les contrôles du temps d\'écran';

  @override
  String get premiumTitleAppStats =>
      'Débloquer les analyses d\'utilisation des apps';

  @override
  String get premiumTitleAchievements => 'Débloquer les succès et récompenses';

  @override
  String get premiumTitleLoudAlarm => 'Débloquer l\'alarme sonore à distance';

  @override
  String get premiumTitleFullMenu => 'Débloquer le menu parent complet';

  @override
  String get premiumTitleGeneric => 'Débloquer Family Security Pro';

  @override
  String get premiumSubtitleAdditionalChildren =>
      'Les comptes gratuits ne peuvent gérer qu\'un seul enfant. Mettez à niveau pour ajouter toute la famille.';

  @override
  String get premiumSubtitleLiveMap =>
      'Voir la localisation en temps réel, le statut et les actions à distance depuis une seule carte.';

  @override
  String get premiumSubtitleMovementHistory =>
      'Consulter les itinéraires historiques, rejouer les déplacements et examiner les changements de position.';

  @override
  String get premiumSubtitleAudioMonitoring =>
      'Écoutez le son ambiant près de l\'enfant lorsque vous avez besoin d\'un contexte immédiat.';

  @override
  String get premiumSubtitleScreenTime =>
      'Définir les limites quotidiennes des applications, bloquer les applications et promouvoir de meilleures habitudes.';

  @override
  String get premiumSubtitleAppStats =>
      'Voir les répartitions d\'utilisation, les tendances et les informations sur le comportement des applications.';

  @override
  String get premiumSubtitleAchievements =>
      'Utilisez des tâches, des étoiles et des récompenses pour inculquer de bonnes habitudes à votre enfant.';

  @override
  String get premiumSubtitleLoudAlarm =>
      'Déclencher une alarme sonore à distance pour localiser rapidement l\'appareil de l\'enfant.';

  @override
  String get premiumSubtitleFullMenu =>
      'Le menu parent avancé, les contrôles et les outils de surveillance font partie de Pro.';

  @override
  String get premiumSubtitleGeneric =>
      'Passez à Family Security Pro pour débloquer des outils avancés de contrôle parental et de surveillance.';

  @override
  String get seePlans => 'Voir les plans';
}
