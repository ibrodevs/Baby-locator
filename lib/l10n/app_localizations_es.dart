// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'Inicia sesión o crea una cuenta de padre';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createParentAccount => 'Crear cuenta de padre';

  @override
  String get childrenSignInHint =>
      'Los niños inician sesión con las credenciales creadas por su padre.';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get displayName => 'Nombre visible';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get navMap => 'Mapa';

  @override
  String get navActivity => 'Actividad';

  @override
  String get navChat => 'Chat';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navHome => 'Inicio';

  @override
  String get waitingForLocation =>
      'Esperando a que los niños compartan su ubicación...';

  @override
  String get addChildToTrack => 'Añade un niño para empezar a rastrear';

  @override
  String get manageChildren => 'Gestionar niños';

  @override
  String get loud => 'ALTO';

  @override
  String get around => 'ALREDEDOR';

  @override
  String get currentLocation => 'UBICACIÓN ACTUAL';

  @override
  String messageChild(String childName) {
    return 'Mensaje a $childName';
  }

  @override
  String get history => 'Historial';

  @override
  String lastUpdated(String time) {
    return 'Última actualización: $time';
  }

  @override
  String get statusActive => 'ACTIVO';

  @override
  String get statusPaused => 'PAUSADO';

  @override
  String get statusOffline => 'SIN CONEXIÓN';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(int minutes) {
    return 'hace ${minutes}m';
  }

  @override
  String hoursAgo(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get addChildToSeeActivity => 'Añade un niño para ver la actividad';

  @override
  String get activity => 'Actividad';

  @override
  String get today => 'Hoy';

  @override
  String get leftArea => 'Abandonó el área';

  @override
  String get arrivedAtLocation => 'Llegó a la ubicación';

  @override
  String get phoneCharging => 'Teléfono cargando';

  @override
  String batteryReached(int battery) {
    return 'Batería al $battery%';
  }

  @override
  String get batteryLow => 'Batería baja';

  @override
  String batteryDropped(int battery) {
    return 'La batería bajó al $battery%';
  }

  @override
  String get currentLocationTitle => 'Ubicación actual';

  @override
  String get locationShared => 'Ubicación compartida';

  @override
  String get batteryStatus => 'Estado de batería';

  @override
  String batteryAt(int battery) {
    return 'Batería al $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Sin actividad aún. Los eventos aparecerán cuando $childName comparta su ubicación.';
  }

  @override
  String get safeZones => 'Lugares';

  @override
  String get addNew => 'Añadir nueva';

  @override
  String get noSafeZonesYet => 'Aún no hay lugares';

  @override
  String zone(String zoneName) {
    return 'Lugar: $zoneName';
  }

  @override
  String get editZone => 'Editar lugar';

  @override
  String get activeToday => 'ACTIVO HOY';

  @override
  String get inactiveToday => 'INACTIVO HOY';

  @override
  String get disabled => 'DESACTIVADO';

  @override
  String get dailySafetyScore => 'Puntuación de seguridad diaria';

  @override
  String get noLocationUpdatesYet => 'Sin actualizaciones de ubicación hoy';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates de $totalUpdates actualizaciones estuvieron dentro de zonas seguras hoy';
  }

  @override
  String coverage(int percent) {
    return 'Cobertura: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Lugar actual: $zoneName';
  }

  @override
  String get addSafeZone => 'Añadir nuevo lugar';

  @override
  String get editSafeZone => 'Editar lugar';

  @override
  String get deleteZoneTitle => '¿Eliminar lugar?';

  @override
  String get deleteZoneMessage => 'Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get zoneEnabled => 'LUGAR ACTIVO';

  @override
  String get zoneName => 'NOMBRE DEL LUGAR';

  @override
  String get zoneNameHint => 'p. ej. Casa, Escuela';

  @override
  String get activeWhen => 'ACTIVO CUANDO';

  @override
  String get always => 'Siempre';

  @override
  String get daysOfWeek => 'Días de la semana';

  @override
  String get chooseAtLeastOneDay => 'Elige al menos un día para este horario.';

  @override
  String get radius => 'RADIO';

  @override
  String get locationMoveMap =>
      'UBICACIÓN (Mueve el mapa para fijar el centro)';

  @override
  String get moveMapToSetCenter =>
      'Mueve el mapa para fijar el centro del lugar';

  @override
  String get createSafeZone => 'Crear lugar';

  @override
  String get updateSafeZone => 'Actualizar lugar';

  @override
  String get pleaseEnterZoneName => 'Introduce un nombre para el lugar';

  @override
  String get chooseAtLeastOneDayError => 'Elige al menos un día activo';

  @override
  String get addChildToChat => 'Añade un niño para empezar a chatear';

  @override
  String get noMessagesYet => 'Aún no hay mensajes. ¡Di hola!';

  @override
  String get sendMessage => 'Escribe un mensaje...';

  @override
  String failedToSend(String error) {
    return 'Error al enviar: $error';
  }

  @override
  String helloUser(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get kidMode => 'Modo niño';

  @override
  String get myLocation => 'Mi ubicación';

  @override
  String get waitingForGps => 'Esperando GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Compartido con el padre · $time';
  }

  @override
  String get notSharedYet => 'Aún no compartido';

  @override
  String get imSafe => 'Estoy bien';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'Enviado \"Estoy bien\" a tu padre';

  @override
  String get sosMessage => '¡SOS! ¡Necesito ayuda!';

  @override
  String sosLocation(String address) {
    return ' Ubicación: $address';
  }

  @override
  String get sosSent => 'SOS enviado — el padre será notificado';

  @override
  String get allowUsageAccess => 'Permitir acceso al uso de apps';

  @override
  String get usageAccessDescription =>
      'Esto permite que el panel de control del padre muestre datos reales de tiempo de pantalla y límites de apps desde este teléfono.';

  @override
  String get openUsageAccess => 'Abrir acceso de uso';

  @override
  String syncError(String error) {
    return 'Error de sincronización: $error';
  }

  @override
  String get iphoneLimitation => 'Limitación del iPhone';

  @override
  String get iphoneUsageDescription =>
      'En iPhone no existe una pantalla de Acceso de uso al estilo Android. El tiempo de pantalla por app y el bloqueo directo de apps requieren las APIs de Screen Time de Apple y permisos especiales, por lo que este botón no funciona en iOS.';

  @override
  String get turnOnLocation => 'Activar servicios de ubicación';

  @override
  String get locationIsOff =>
      'La ubicación está desactivada. Actívala para compartir con el padre.';

  @override
  String get openLocationSettings => 'Abrir ajustes de ubicación';

  @override
  String get locationBlocked => 'Permiso de ubicación bloqueado';

  @override
  String get enableLocationAccess =>
      'Activa el acceso a la ubicación en los ajustes del sistema.';

  @override
  String get openAppSettings => 'Abrir ajustes de la app';

  @override
  String get allowLocationToShare => 'Permite la ubicación para compartir';

  @override
  String get grantLocationPermission =>
      'Concede permiso para que tu padre pueda ver dónde estás.';

  @override
  String get allowLocation => 'Permitir ubicación';

  @override
  String get myChildren => 'Mis hijos';

  @override
  String get addChild => 'Añadir hijo';

  @override
  String get noChildrenYet =>
      'Aún no hay hijos. Toca \"Añadir hijo\" para crear uno.';

  @override
  String get parentAccount => 'Cuenta de padre';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get deleteChildTitle => '¿Eliminar hijo?';

  @override
  String deleteChildMessage(String childName) {
    return '¿Eliminar a $childName y todo el historial de actividad vinculado?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName eliminado';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Error al eliminar hijo: $error';
  }

  @override
  String get avatarUpdated => 'Avatar actualizado';

  @override
  String failedGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get createChildAccount => 'Crear cuenta de hijo';

  @override
  String get childSignInHint =>
      'Tu hijo iniciará sesión con estas credenciales en su dispositivo.';

  @override
  String get displayNameHint => 'Nombre visible (p. ej. Álex)';

  @override
  String get create => 'Crear';

  @override
  String get editChildProfile => 'Editar perfil del hijo';

  @override
  String get save => 'Guardar';

  @override
  String get deleteChild => 'Eliminar hijo';

  @override
  String get track => 'Rastrear';

  @override
  String get edit => 'Editar';

  @override
  String get settings => 'Ajustes';

  @override
  String get parent => 'PADRE';

  @override
  String get child => 'HIJO';

  @override
  String get editProfileDetails => 'Editar detalles del perfil';

  @override
  String get account => 'Cuenta';

  @override
  String get manageChildrenMenu => 'Gestionar hijos';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get locationAlerts => 'Alertas de ubicación';

  @override
  String get batteryAlerts => 'Alertas de batería';

  @override
  String get safeZoneAlerts => 'Alertas de lugares';

  @override
  String get notificationPermissionRequired =>
      'Se requiere permiso de notificaciones para enviar alertas';

  @override
  String get general => 'General';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get helpAndSupport => 'Ayuda y soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get updateProfileHint => 'Actualiza tu nombre visible y usuario.';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get usernameCannotBeEmpty =>
      'El nombre de usuario no puede estar vacío';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String failedToUploadAvatar(String error) {
    return 'Error al subir el avatar: $error';
  }

  @override
  String get parentProfile => 'Perfil del padre';

  @override
  String get addChildForStats =>
      'Añade una cuenta de hijo primero para ver estadísticas en vivo.';

  @override
  String get insights => 'ESTADÍSTICAS';

  @override
  String childStats(String childName) {
    return 'Estadísticas de $childName';
  }

  @override
  String get deviceStatus => 'Estado del dispositivo';

  @override
  String batteryPercent(int battery) {
    return '$battery% de batería';
  }

  @override
  String get batteryUnknown => 'Batería desconocida';

  @override
  String synced(String time) {
    return 'Sincronizado $time';
  }

  @override
  String get noDeviceSyncYet => 'Aún no hay sincronización del dispositivo';

  @override
  String get usageAccessGranted => 'Acceso de uso concedido';

  @override
  String get usageAccessNeeded => 'Se necesita acceso de uso';

  @override
  String get iosUsageAccessNote =>
      'Este dispositivo es un iPhone. iOS no proporciona Acceso de uso al estilo Android, por lo que esta app no puede abrir esa pantalla de permisos. El tiempo de pantalla y el bloqueo de apps en iPhone requieren permisos de Screen Time de Apple y una integración nativa independiente.';

  @override
  String get androidUsageAccessNote =>
      'Abre la app del hijo en el teléfono y permite el acceso de uso. Después, el tiempo de pantalla, los límites de apps y el calendario se sincronizarán automáticamente.';

  @override
  String get dailyUsage => 'Uso diario';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total de $limit usado';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total usado el $date';
  }

  @override
  String get allLimitsInRange =>
      'Todos los límites activados están dentro del rango';

  @override
  String appLimitExceeded(int count) {
    return '$count límite de app superado hoy';
  }

  @override
  String get setAppLimitsHint =>
      'Establece límites de apps abajo para convertir esto en un objetivo real.';

  @override
  String get weeklyUsage => 'Uso semanal';

  @override
  String get usageCalendar => 'Calendario de uso';

  @override
  String get noAppUsageData => 'Aún no hay datos de uso de apps para este día.';

  @override
  String get grantUsageAccessHint =>
      'Concede acceso de uso en el teléfono del hijo para ver datos reales de apps y gestionar límites.';

  @override
  String get iosAppLimitsUnavailable =>
      'Este teléfono es un iPhone. La versión actual de la app no tiene integración con Apple Screen Time, por lo que el uso por app y los límites directos de apps no están disponibles en iOS.';

  @override
  String get enableDailyLimit => 'Activar límite diario';

  @override
  String get dailyLimit => 'Límite diario';

  @override
  String get saveLimit => 'Guardar límite';

  @override
  String get manageAppLimits => 'Gestionar límites de apps';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName usado el $date';
  }

  @override
  String limitMinutes(String time) {
    return 'Límite $time';
  }

  @override
  String get noLimit => 'Sin límite';

  @override
  String usageTodayOverLimit(String time) {
    return '$time hoy · por encima del límite';
  }

  @override
  String usageToday(String time) {
    return '$time hoy';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Límite guardado para $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Límite desactivado para $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'No se pudo guardar el límite: $error';
  }

  @override
  String get mon => 'LUN';

  @override
  String get tue => 'MAR';

  @override
  String get wed => 'MIÉ';

  @override
  String get thu => 'JUE';

  @override
  String get fri => 'VIE';

  @override
  String get sat => 'SÁB';

  @override
  String get sun => 'DOM';

  @override
  String get over => 'SUPERADO';

  @override
  String get onboardingTitle => '¡Bienvenido!';

  @override
  String get onboardingSubtitle => '¿Quién eres?';

  @override
  String get iAmParent => 'Soy madre o padre';

  @override
  String get iAmChild => 'Soy un niño';

  @override
  String get parentSignIn => 'Iniciar sesión';

  @override
  String get parentCreateAccount => 'Crear cuenta';

  @override
  String get parentAuthSubtitle => 'Administra y protege a tu familia';

  @override
  String get childSignIn => 'Iniciar sesión';

  @override
  String get childAuthTitle => '¡Hola!';

  @override
  String get childAuthSubtitle => 'Pide a tu madre o padre tus datos de acceso';

  @override
  String get childNavSettings => 'Ajustes';

  @override
  String get childProfile => 'Perfil';

  @override
  String get childSettingsTitle => 'Ajustes';

  @override
  String get childLogout => 'Cerrar sesión';

  @override
  String get inviteChild => 'Invitar al hijo';

  @override
  String get inviteTitle =>
      'Invita a tus hijos y otros familiares a tu círculo';

  @override
  String get inviteSubtitle =>
      'Los miembros de tu familia deben instalar la app y unirse al círculo con el código';

  @override
  String get inviteCodeLabel => 'Código válido por 3 días';

  @override
  String get shareCode => 'Compartir código';

  @override
  String get getHelp => 'Obtener ayuda';

  @override
  String get generateCode => 'Generar código';

  @override
  String get codeCopied => 'Código copiado al portapapeles';

  @override
  String inviteShareText(String code) {
    return '¡Únete a mi círculo familiar en Family security! Usa el código de invitación: $code\n\nhttp://89.108.81.151/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'Error al generar código: $error';
  }

  @override
  String get childRegisterTitle => 'Unirse a la familia';

  @override
  String get childRegisterSubtitle =>
      'Introduce el código de invitación de tu padre/madre';

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get next => 'Siguiente';

  @override
  String get setupYourProfile => 'Configurar tu perfil';

  @override
  String get enterYourDetails => 'Introduce tu nombre para mostrar';

  @override
  String get register => 'Registrarse';

  @override
  String get invalidInviteCode => 'Código de invitación inválido o expirado';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Iniciar sesión';

  @override
  String get dontHaveCode => '¿Tienes un código de invitación? Regístrate';

  @override
  String get placesOnMap => 'Lugares en el mapa';

  @override
  String get placesAndChildren => 'Lugares y niños';

  @override
  String placesCount(int count) {
    return 'Lugares: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'Activos hoy: $count';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get createPlaceHint =>
      'Crea un lugar para recibir avisos cuando tu hijo llegue o se vaya.';

  @override
  String get untitledPlace => 'Lugar sin nombre';

  @override
  String get placeDeleted => 'Lugar eliminado.';

  @override
  String get editLabel => 'Editar';

  @override
  String get disabledSchedule => 'Desactivado';

  @override
  String get noDaysSelected => 'No hay días seleccionados';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'Radio $radius • $schedule';
  }

  @override
  String get proActive => 'Pro activo';

  @override
  String get freePlan => 'Plan gratuito';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get skip => 'Saltar';

  @override
  String get getPremium => 'Obtener Premium';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get bestValue => 'Mejor valor';

  @override
  String get perMonth => 'por mes';

  @override
  String get perYearSave58 => 'por año · Ahorra 58%';

  @override
  String get paywallProductName => 'Family Security Pro';

  @override
  String get paywallUpgrade => 'Actualizar';

  @override
  String paywallBestValueSave(int percent) {
    return 'Mejor valor · Ahorra $percent%';
  }

  @override
  String get paywallBenefitAddChildren =>
      'Añade varios hijos a una cuenta familiar';

  @override
  String get paywallBenefitUnlockTools =>
      'Desbloquea monitoreo de audio, mapa en vivo, historial, estadísticas y alarmas';

  @override
  String get paywallBenefitFullDashboard =>
      'Mantén disponible todo el panel de padres sin límites del plan gratuito';

  @override
  String get paywallBenefitAudio =>
      'Audio del entorno en tiempo real cerca del dispositivo del hijo';

  @override
  String get paywallBenefitAppLimits =>
      'Límites de apps, análisis de uso e historial de movimiento';

  @override
  String get paywallBenefitAlarm =>
      'Alarma sonora, logros y controles parentales avanzados';

  @override
  String get paywallIncludedWithPro => 'Incluido con Pro';

  @override
  String get paywallPlansTitle => 'Planes disponibles';

  @override
  String get paywallRecommended => 'Recomendado';

  @override
  String paywallPerMonthEquivalent(String price) {
    return '$price equivalente mensual';
  }

  @override
  String get paywallChooseYourPlan => 'Elige tu plan';

  @override
  String get paywallChoosePlanDescription =>
      'Elige el plan mensual o anual de Family Security Pro que mejor se adapte a tu familia.';

  @override
  String get paywallLoadingPlans => 'Cargando planes de suscripción...';

  @override
  String get paywallNoOffering =>
      'No hay ninguna oferta disponible actualmente.';

  @override
  String get paywallPlatformOnly =>
      'Los muros de pago están disponibles solo en iOS y Android en esta versión.';

  @override
  String get subscriptionRestored => 'Tu suscripción ha sido restaurada.';

  @override
  String get noSubscriptionFound =>
      'No se encontró ninguna suscripción activa para restaurar.';

  @override
  String get subscriptionNowActive => 'Family Security Pro está ahora activo.';

  @override
  String get purchaseEntitlementPending =>
      'Compra finalizada, pero la suscripción aún no está activa.';

  @override
  String get premiumTitleAdditionalChildren =>
      'Desbloquear más perfiles de hijos';

  @override
  String get premiumTitleLiveMap => 'Desbloquear mapa familiar en tiempo real';

  @override
  String get premiumTitleMovementHistory =>
      'Desbloquear historial de movimiento';

  @override
  String get premiumTitleAudioMonitoring =>
      'Desbloquear sonido ambiente en tiempo real';

  @override
  String get premiumTitleScreenTime =>
      'Desbloquear controles de tiempo de pantalla';

  @override
  String get premiumTitleAppStats => 'Desbloquear análisis de uso de apps';

  @override
  String get premiumTitleAchievements => 'Desbloquear logros y recompensas';

  @override
  String get premiumTitleLoudAlarm =>
      'Desbloquear alarma remota de alto volumen';

  @override
  String get premiumTitleFullMenu => 'Desbloquear el menú completo de padres';

  @override
  String get premiumTitleGeneric => 'Desbloquear Family Security Pro';

  @override
  String get premiumSubtitleAdditionalChildren =>
      'Las cuentas gratuitas solo pueden gestionar un hijo. Actualiza para añadir a toda la familia.';

  @override
  String get premiumSubtitleLiveMap =>
      'Ve la ubicación en tiempo real, el estado y las acciones remotas de tus hijos desde un mapa.';

  @override
  String get premiumSubtitleMovementHistory =>
      'Revisa rutas históricas, reproduce movimientos e investiga cambios de ubicación.';

  @override
  String get premiumSubtitleAudioMonitoring =>
      'Escucha los sonidos del entorno cerca del hijo cuando necesitas contexto inmediato.';

  @override
  String get premiumSubtitleScreenTime =>
      'Establece límites diarios de apps, bloquea apps y fomenta hábitos más saludables.';

  @override
  String get premiumSubtitleAppStats =>
      'Ve desglose de uso, tendencias e insights de comportamiento a nivel de app.';

  @override
  String get premiumSubtitleAchievements =>
      'Usa tareas, estrellas y recompensas para desarrollar hábitos positivos en tu hijo.';

  @override
  String get premiumSubtitleLoudAlarm =>
      'Activa una alarma sonora de forma remota para localizar rápidamente el dispositivo del hijo.';

  @override
  String get premiumSubtitleFullMenu =>
      'El menú avanzado de padres, los controles y las herramientas de monitoreo son parte de Pro.';

  @override
  String get premiumSubtitleGeneric =>
      'Actualiza a Family Security Pro para desbloquear herramientas avanzadas de control parental.';

  @override
  String get seePlans => 'Ver planes';
}
