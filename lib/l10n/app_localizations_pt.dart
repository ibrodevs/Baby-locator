// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Kid Security';

  @override
  String get signInOrCreate => 'Entrar ou criar uma conta de responsável';

  @override
  String get signIn => 'Entrar';

  @override
  String get createParentAccount => 'Criar conta de responsável';

  @override
  String get childrenSignInHint =>
      'As crianças entram com as credenciais criadas pelo seu responsável.';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get username => 'Nome de usuário';

  @override
  String get password => 'Senha';

  @override
  String get navMap => 'Mapa';

  @override
  String get navActivity => 'Atividade';

  @override
  String get navChat => 'Chat';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get navHome => 'Início';

  @override
  String get waitingForLocation =>
      'Aguardando as crianças compartilharem a localização...';

  @override
  String get addChildToTrack =>
      'Adicione uma criança para começar o rastreamento';

  @override
  String get manageChildren => 'Gerenciar crianças';

  @override
  String get loud => 'ALTO';

  @override
  String get around => 'POR PERTO';

  @override
  String get currentLocation => 'LOCALIZAÇÃO ATUAL';

  @override
  String messageChild(String childName) {
    return 'Mensagem para $childName';
  }

  @override
  String get history => 'Histórico';

  @override
  String lastUpdated(String time) {
    return 'Última atualização: $time';
  }

  @override
  String get statusActive => 'ATIVO';

  @override
  String get statusPaused => 'PAUSADO';

  @override
  String get statusOffline => 'OFFLINE';

  @override
  String get justNow => 'Agora mesmo';

  @override
  String minutesAgo(int minutes) {
    return 'Há $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Há $hours h';
  }

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get addChildToSeeActivity =>
      'Adicione uma criança para ver a atividade';

  @override
  String get activity => 'Atividade';

  @override
  String get today => 'Hoje';

  @override
  String get leftArea => 'Saiu da área';

  @override
  String get arrivedAtLocation => 'Chegou ao local';

  @override
  String get phoneCharging => 'Telefone carregando';

  @override
  String batteryReached(int battery) {
    return 'Bateria chegou a $battery%';
  }

  @override
  String get batteryLow => 'Bateria fraca';

  @override
  String batteryDropped(int battery) {
    return 'Bateria caiu para $battery%';
  }

  @override
  String get currentLocationTitle => 'Localização atual';

  @override
  String get locationShared => 'Localização compartilhada';

  @override
  String get batteryStatus => 'Status da bateria';

  @override
  String batteryAt(int battery) {
    return 'Bateria em $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'Nenhuma atividade ainda. Os eventos aparecerão quando $childName compartilhar sua localização.';
  }

  @override
  String get safeZones => 'Zonas seguras';

  @override
  String get addNew => 'Adicionar';

  @override
  String get noSafeZonesYet => 'Nenhuma zona segura ainda';

  @override
  String zone(String zoneName) {
    return 'Zona: $zoneName';
  }

  @override
  String get editZone => 'Editar zona';

  @override
  String get activeToday => 'ATIVO HOJE';

  @override
  String get inactiveToday => 'INATIVO HOJE';

  @override
  String get disabled => 'DESATIVADO';

  @override
  String get dailySafetyScore => 'Pontuação de segurança diária';

  @override
  String get noLocationUpdatesYet => 'Nenhuma atualização de localização hoje';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates de $totalUpdates atualizações estavam em zonas seguras hoje';
  }

  @override
  String coverage(int percent) {
    return 'Cobertura: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'Zona atual: $zoneName';
  }

  @override
  String get addSafeZone => 'Adicionar zona segura';

  @override
  String get editSafeZone => 'Editar zona segura';

  @override
  String get deleteZoneTitle => 'Excluir zona?';

  @override
  String get deleteZoneMessage => 'Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get zoneEnabled => 'ZONA ATIVADA';

  @override
  String get zoneName => 'NOME DA ZONA';

  @override
  String get zoneNameHint => 'ex. Casa, Escola';

  @override
  String get activeWhen => 'ATIVO QUANDO';

  @override
  String get always => 'Sempre';

  @override
  String get daysOfWeek => 'Dias da semana';

  @override
  String get chooseAtLeastOneDay =>
      'Escolha pelo menos um dia para este horário.';

  @override
  String get radius => 'RAIO';

  @override
  String get locationMoveMap =>
      'LOCALIZAÇÃO (Mova o mapa para centralizar o pin)';

  @override
  String get moveMapToSetCenter => 'Mova o mapa para definir o centro da zona';

  @override
  String get createSafeZone => 'Criar zona segura';

  @override
  String get updateSafeZone => 'Atualizar zona segura';

  @override
  String get pleaseEnterZoneName => 'Por favor, insira um nome para a zona';

  @override
  String get chooseAtLeastOneDayError => 'Escolha pelo menos um dia ativo';

  @override
  String get addChildToChat => 'Adicione uma criança para começar a conversar';

  @override
  String get noMessagesYet => 'Nenhuma mensagem ainda. Diga olá!';

  @override
  String get sendMessage => 'Enviar uma mensagem...';

  @override
  String failedToSend(String error) {
    return 'Falha ao enviar: $error';
  }

  @override
  String helloUser(String name) {
    return 'Olá, $name!';
  }

  @override
  String get kidMode => 'Modo infantil';

  @override
  String get myLocation => 'Minha localização';

  @override
  String get waitingForGps => 'Aguardando GPS...';

  @override
  String sharedWithParent(String time) {
    return 'Compartilhado com o responsável · $time';
  }

  @override
  String get notSharedYet => 'Ainda não compartilhado';

  @override
  String get imSafe => 'Estou seguro';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => '\"Estou seguro\" enviado ao seu responsável';

  @override
  String get sosMessage => 'SOS! Preciso de ajuda!';

  @override
  String sosLocation(String address) {
    return ' Localização: $address';
  }

  @override
  String get sosSent => 'SOS enviado — o responsável será notificado';

  @override
  String get allowUsageAccess => 'Permitir acesso de uso';

  @override
  String get usageAccessDescription =>
      'Isso permite que o painel do responsável exiba dados reais de tempo de tela e limites de aplicativos deste telefone.';

  @override
  String get openUsageAccess => 'Abrir acesso de uso';

  @override
  String syncError(String error) {
    return 'Erro de sincronização: $error';
  }

  @override
  String get iphoneLimitation => 'Limitação do iPhone';

  @override
  String get iphoneUsageDescription =>
      'No iPhone não há uma tela de acesso de uso como no Android. O tempo de tela real por aplicativo e o bloqueio direto de apps precisam das APIs Screen Time da Apple e de permissões especiais, portanto este botão não funciona no iOS.';

  @override
  String get turnOnLocation => 'Ativar serviços de localização';

  @override
  String get locationIsOff =>
      'A localização está desativada. Ative-a para compartilhar com o responsável.';

  @override
  String get openLocationSettings => 'Abrir configurações de localização';

  @override
  String get locationBlocked => 'Permissão de localização bloqueada';

  @override
  String get enableLocationAccess =>
      'Ative o acesso à localização nas configurações do sistema.';

  @override
  String get openAppSettings => 'Abrir configurações do aplicativo';

  @override
  String get allowLocationToShare => 'Permitir localização para compartilhar';

  @override
  String get grantLocationPermission =>
      'Conceda permissão para que seu responsável possa ver onde você está.';

  @override
  String get allowLocation => 'Permitir localização';

  @override
  String get myChildren => 'Meus filhos';

  @override
  String get addChild => 'Adicionar filho';

  @override
  String get noChildrenYet =>
      'Nenhum filho ainda. Toque em \"Adicionar filho\" para criar um.';

  @override
  String get parentAccount => 'Conta do responsável';

  @override
  String get changePhoto => 'Alterar foto';

  @override
  String get deleteChildTitle => 'Excluir filho?';

  @override
  String deleteChildMessage(String childName) {
    return 'Excluir $childName e todo o histórico de atividades vinculado?';
  }

  @override
  String childDeleted(String childName) {
    return '$childName excluído';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'Falha ao excluir filho: $error';
  }

  @override
  String get avatarUpdated => 'Avatar atualizado';

  @override
  String failedGeneric(String error) {
    return 'Falha: $error';
  }

  @override
  String get createChildAccount => 'Criar conta infantil';

  @override
  String get childSignInHint =>
      'Seu filho entrará com essas credenciais no dispositivo dele.';

  @override
  String get displayNameHint => 'Nome de exibição (ex. Alex)';

  @override
  String get create => 'Criar';

  @override
  String get editChildProfile => 'Editar perfil do filho';

  @override
  String get save => 'Salvar';

  @override
  String get deleteChild => 'Excluir filho';

  @override
  String get track => 'Rastrear';

  @override
  String get edit => 'Editar';

  @override
  String get settings => 'Configurações';

  @override
  String get parent => 'RESPONSÁVEL';

  @override
  String get child => 'FILHO';

  @override
  String get editProfileDetails => 'Editar detalhes do perfil';

  @override
  String get account => 'Conta';

  @override
  String get manageChildrenMenu => 'Gerenciar filhos';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get notifications => 'Notificações';

  @override
  String get pushNotifications => 'Notificações push';

  @override
  String get locationAlerts => 'Alertas de localização';

  @override
  String get batteryAlerts => 'Alertas de bateria';

  @override
  String get safeZoneAlerts => 'Alertas de zonas seguras';

  @override
  String get notificationPermissionRequired =>
      'A permissão de notificação é necessária para enviar alertas';

  @override
  String get general => 'Geral';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get helpAndSupport => 'Ajuda e suporte';

  @override
  String get about => 'Sobre';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get signOut => 'Sair';

  @override
  String get appVersion => 'Kid Security v1.0.0';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get updateProfileHint =>
      'Atualize seu nome de exibição e nome de usuário.';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get usernameCannotBeEmpty => 'O nome de usuário não pode estar vazio';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String failedToUploadAvatar(String error) {
    return 'Falha ao enviar avatar: $error';
  }

  @override
  String get parentProfile => 'Perfil do responsável';

  @override
  String get addChildForStats =>
      'Adicione uma conta infantil primeiro para ver estatísticas em tempo real.';

  @override
  String get insights => 'INSIGHTS';

  @override
  String childStats(String childName) {
    return 'Estatísticas de $childName';
  }

  @override
  String get deviceStatus => 'Status do dispositivo';

  @override
  String batteryPercent(int battery) {
    return '$battery% de bateria';
  }

  @override
  String get batteryUnknown => 'Bateria desconhecida';

  @override
  String synced(String time) {
    return 'Sincronizado $time';
  }

  @override
  String get noDeviceSyncYet => 'Nenhuma sincronização de dispositivo ainda';

  @override
  String get usageAccessGranted => 'Acesso de uso concedido';

  @override
  String get usageAccessNeeded => 'Acesso de uso necessário';

  @override
  String get iosUsageAccessNote =>
      'Este dispositivo infantil é um iPhone. O iOS não fornece acesso de uso Android, portanto este aplicativo não pode abrir essa tela de permissão. O tempo de tela real do iPhone e o bloqueio de apps precisam de permissões Screen Time da Apple e de uma integração nativa separada.';

  @override
  String get androidUsageAccessNote =>
      'Abra o aplicativo infantil no telefone e permita o acesso de uso. Depois disso, o tempo de tela, os limites de apps e o calendário sincronizarão automaticamente.';

  @override
  String get dailyUsage => 'Uso diário';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total de $limit usado';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total usado em $date';
  }

  @override
  String get allLimitsInRange =>
      'Todos os limites ativados estão dentro do intervalo';

  @override
  String appLimitExceeded(int count) {
    return '$count limite de aplicativo excedido hoje';
  }

  @override
  String get setAppLimitsHint =>
      'Defina limites de aplicativos abaixo para transformar isso em uma meta real.';

  @override
  String get weeklyUsage => 'Uso semanal';

  @override
  String get usageCalendar => 'Calendário de uso';

  @override
  String get noAppUsageData =>
      'Nenhum dado de uso de aplicativo para este dia ainda.';

  @override
  String get grantUsageAccessHint =>
      'Conceda acesso de uso no telefone do filho para ver dados reais de apps e gerenciar limites.';

  @override
  String get iosAppLimitsUnavailable =>
      'Este telefone infantil é um iPhone. A versão atual do aplicativo ainda não tem integração com o Apple Screen Time, portanto o uso real por aplicativo e os limites diretos não estão disponíveis no iOS.';

  @override
  String get enableDailyLimit => 'Ativar limite diário';

  @override
  String get dailyLimit => 'Limite diário';

  @override
  String get saveLimit => 'Salvar limite';

  @override
  String get manageAppLimits => 'Gerenciar limites de aplicativos';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName usado em $date';
  }

  @override
  String limitMinutes(String time) {
    return 'Limite $time';
  }

  @override
  String get noLimit => 'Sem limite';

  @override
  String usageTodayOverLimit(String time) {
    return '$time hoje · acima do limite';
  }

  @override
  String usageToday(String time) {
    return '$time hoje';
  }

  @override
  String limitSavedFor(String appName) {
    return 'Limite salvo para $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'Limite desativado para $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'Não foi possível salvar o limite: $error';
  }

  @override
  String get mon => 'SEG';

  @override
  String get tue => 'TER';

  @override
  String get wed => 'QUA';

  @override
  String get thu => 'QUI';

  @override
  String get fri => 'SEX';

  @override
  String get sat => 'SÁB';

  @override
  String get sun => 'DOM';

  @override
  String get over => 'EXCEDIDO';

  @override
  String get onboardingTitle => 'Bem-vindo!';

  @override
  String get onboardingSubtitle => 'Quem é você?';

  @override
  String get iAmParent => 'Sou responsável';

  @override
  String get iAmChild => 'Sou uma criança';

  @override
  String get parentSignIn => 'Entrar';

  @override
  String get parentCreateAccount => 'Criar conta';

  @override
  String get parentAuthSubtitle => 'Gerencie e proteja sua família';

  @override
  String get childSignIn => 'Entrar';

  @override
  String get childAuthTitle => 'Olá!';

  @override
  String get childAuthSubtitle =>
      'Peça ao seu responsável seus dados de acesso';

  @override
  String get childNavSettings => 'Configurações';

  @override
  String get childProfile => 'Perfil';

  @override
  String get childSettingsTitle => 'Configurações';

  @override
  String get childLogout => 'Sair';
}
