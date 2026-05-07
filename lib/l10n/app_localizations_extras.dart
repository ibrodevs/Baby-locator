import 'package:flutter/widgets.dart';
import 'package:kid_security/l10n/app_localizations.dart';

String pickLocalizedExtra(String localeName, Map<String, String> values) {
  final languageCode = localeName.split('_').first.toLowerCase();
  return values[languageCode] ?? values['en']!;
}

String fillLocalizedExtra(String template, Map<String, Object> values) {
  var result = template;
  for (final entry in values.entries) {
    result = result.replaceAll('{${entry.key}}', '${entry.value}');
  }
  return result;
}

class ExtraL10n {
  ExtraL10n(this.localeName);

  factory ExtraL10n.of(BuildContext context) =>
      ExtraL10n(S.of(context).localeName);

  final String localeName;

  String _pick(Map<String, String> values) =>
      pickLocalizedExtra(localeName, values);
  String _fill(String template, Map<String, Object> values) =>
      fillLocalizedExtra(template, values);

  String get okAction => _pick({
        'en': 'OK',
        'ru': 'ОК',
      });

  String get childLabel => _pick({
        'en': 'Child',
        'ru': 'Ребёнок',
      });

  String get menuLabel => _pick({
        'en': 'Menu',
        'ru': 'Меню',
      });

  String get childPermissionsTitle => _pick({
        'en': 'Child permissions',
        'ru': 'Разрешения ребёнка',
      });

  String get tapAvatarToSet => _pick({
        'en': 'Tap the photo to set an avatar.',
        'ru': 'Нажмите на фото, чтобы поставить аватар.',
      });

  String get permissionsTitle => _pick({
        'en': 'Permissions',
        'ru': 'Разрешения',
      });

  String get addChildToSeePermissions => _pick({
        'en': 'Add a child first to see their permissions.',
        'ru': 'Сначала добавьте ребёнка, чтобы увидеть его разрешения.',
      });

  String get statusesNotSyncedYet => _pick({
        'en': 'Statuses have not synced yet',
        'ru': 'Статусы ещё не синхронизированы',
      });

  String lastSyncAt(String time) => _fill(
        _pick({
          'en': 'Last synced: {time}',
          'ru': 'Последняя синхронизация: {time}',
        }),
        {'time': time},
      );

  String get locationEnabledTitle => _pick({
        'en': 'Location enabled',
        'ru': 'Геолокация включена',
      });

  String get locationEnabledDescription => _pick({
        'en': 'Location services on the child phone.',
        'ru': 'Службы геолокации на телефоне ребёнка.',
      });

  String get locationPermissionTitle => _pick({
        'en': 'Location access',
        'ru': 'Доступ к геолокации',
      });

  String get locationPermissionDescription => _pick({
        'en': 'Regular permission to access location.',
        'ru': 'Обычное разрешение на доступ к местоположению.',
      });

  String get backgroundLocationTitle => _pick({
        'en': 'Background location',
        'ru': 'Фоновая геолокация',
      });

  String get backgroundLocationDescription => _pick({
        'en': 'Permission to see the child location in the background.',
        'ru': 'Разрешение видеть местоположение ребёнка в фоне.',
      });

  String get notificationsCommandsDescription => _pick({
        'en': 'Needed for commands, alerts, and signals.',
        'ru': 'Нужно для команд, оповещений и сигналов.',
      });

  String get microphoneTitle => _pick({
        'en': 'Microphone',
        'ru': 'Микрофон',
      });

  String get aroundAudioDescription => _pick({
        'en': 'Needed to listen to audio around the child.',
        'ru': 'Нужно для прослушивания звука вокруг ребёнка.',
      });

  String get usageAccessDescriptionParent => _pick({
        'en': 'Needed for app statistics and screen-time limits.',
        'ru': 'Нужно для статистики приложений и ограничений времени.',
      });

  String get accessibilityDescriptionParent => _pick({
        'en': 'Needed to actually block restricted apps.',
        'ru': 'Нужно, чтобы реально блокировать запрещённые приложения.',
      });

  String get noBatteryRestrictionsTitle => _pick({
        'en': 'No battery restrictions',
        'ru': 'Без ограничений батареи',
      });

  String get noBatteryRestrictionsDescription => _pick({
        'en': 'Helps keep the app from being stopped by Android.',
        'ru': 'Помогает приложению не отключаться системой на Android.',
      });

  String get allowedLabel => _pick({
        'en': 'Allowed',
        'ru': 'Разрешено',
      });

  String get notAllowedLabel => _pick({
        'en': 'Not allowed',
        'ru': 'Не разрешено',
      });

  String get chooseBoyOrGirl => _pick({
        'en': 'Choose: boy or girl.',
        'ru': 'Выберите вариант: сын или дочка.',
      });

  String get enterChildNamePrompt => _pick({
        'en': 'Enter the child name.',
        'ru': 'Введите имя ребёнка.',
      });

  String setupFailed(String error) => _fill(
        _pick({
          'en': 'Could not finish setup: {error}',
          'ru': 'Не удалось завершить настройку: {error}',
        }),
        {'error': error},
      );

  String get codeCopied => _pick({
        'en': 'Code copied.',
        'ru': 'Код скопирован.',
      });

  String inviteShareTextShort(String code) => _fill(
        _pick({
          'en':
              'Install Family Security on the child phone and enter this code: {code}\n\nhttp://89.108.81.151/invite/{code}',
          'ru':
              'Установите Family Security на телефон ребёнка и введите код: {code}\n\nhttp://89.108.81.151/invite/{code}',
        }),
        {'code': code},
      );

  String get familySetupTitle => _pick({
        'en': 'Family setup',
        'ru': 'Настройка семьи',
      });

  String familySetupSubtitle(String name) => _fill(
        _pick({
          'en': 'Let’s quickly connect your child, {name}.',
          'ru': 'Поможем быстро подключить ребёнка, {name}.',
        }),
        {'name': name},
      );

  String get continueLabel => _pick({
        'en': 'Continue',
        'ru': 'Продолжить',
      });

  String get saveNameLabel => _pick({
        'en': 'Save name',
        'ru': 'Сохранить имя',
      });

  String get finishSetupLabel => _pick({
        'en': 'Finish setup',
        'ru': 'Завершить настройку',
      });

  String get nextLabel => _pick({
        'en': 'Next',
        'ru': 'Дальше',
      });

  String get openAppLabel => _pick({
        'en': 'Open app',
        'ru': 'Открыть приложение',
      });

  String get boyOrGirlQuestion => _pick({
        'en': 'Do you have a son or a daughter?',
        'ru': 'У вас сын или дочка?',
      });

  String get familySetupStartSubtitle => _pick({
        'en': 'We’ll start by creating the child profile.',
        'ru': 'С этого начнем создание профиля ребёнка.',
      });

  String get sonLabel => _pick({
        'en': 'Son',
        'ru': 'Сын',
      });

  String get createBoyProfile => _pick({
        'en': 'Create a boy profile',
        'ru': 'Создать профиль мальчика',
      });

  String get daughterLabel => _pick({
        'en': 'Daughter',
        'ru': 'Дочка',
      });

  String get createGirlProfile => _pick({
        'en': 'Create a girl profile',
        'ru': 'Создать профиль девочки',
      });

  String get exampleGirlName => _pick({
        'en': 'Olivia',
        'fr': 'Emma',
        'de': 'Mia',
        'pt': 'Maria',
        'it': 'Sofia',
        'es': 'Sofía',
        'ar': 'عائشة',
        'ru': 'София',
        'pl': 'Zofia',
        'kk': 'Айша',
        'ky': 'Айпери',
        'uz': 'Dilnoza',
        'tg': 'Мадина',
        'tk': 'Gülnara',
        'az': 'Leyla',
        'hy': 'Անահիտ',
        'ka': 'ნინო',
      });

  String get exampleBoyName => _pick({
        'en': 'Liam',
        'fr': 'Gabriel',
        'de': 'Leon',
        'pt': 'João',
        'it': 'Leonardo',
        'es': 'Mateo',
        'ar': 'محمد',
        'ru': 'Александр',
        'pl': 'Jakub',
        'kk': 'Алихан',
        'ky': 'Аман',
        'uz': 'Aziz',
        'tg': 'Фирдавс',
        'tk': 'Merdan',
        'az': 'Murad',
        'hy': 'Արման',
        'ka': 'გიორგი',
      });

  String get nameYourDaughter => _pick({
        'en': 'What is your daughter’s name?',
        'ru': 'Как зовут вашу дочку?',
      });

  String get nameYourSon => _pick({
        'en': 'What is your son’s name?',
        'ru': 'Как зовут вашего сына?',
      });

  String get childSeesNameAfterCode => _pick({
        'en':
            'The child will see this name right after signing in with the code.',
        'ru': 'Это имя сразу увидит ребёнок после входа по коду.',
      });

  String get addPhotoTitle => _pick({
        'en': 'Let’s add a photo',
        'ru': 'Добавим фото',
      });

  String get addPhotoSubtitle => _pick({
        'en':
            'This photo will appear in the child profile. You can skip it and add it later.',
        'ru':
            'Это фото появится в профиле ребёнка. Можно пропустить и добавить позже.',
      });

  String get selectPhotoLabel => _pick({
        'en': 'Choose photo',
        'ru': 'Выбрать фото',
      });

  String get chooseAnotherPhotoLabel => _pick({
        'en': 'Tap to choose another photo',
        'ru': 'Нажмите, чтобы выбрать другое фото',
      });

  String get congratulationsLabel => _pick({
        'en': 'Congratulations!',
        'ru': 'Поздравляем!',
      });

  String get childProfileReady => _pick({
        'en':
            'The child profile is ready. Now connect the child phone with the code.',
        'ru':
            'Профиль ребёнка уже готов. Осталось подключить телефон ребёнка по коду.',
      });

  String get installChildAppTitle => _pick({
        'en': 'Install the app for the child',
        'ru': 'Установите приложение для ребёнка',
      });

  String openChildAppAndEnterCode(String childName) => _fill(
        _pick({
          'en': 'Open the app on {childName}’s phone and enter this code.',
          'ru':
              'Откройте приложение на телефоне {childName} и введите этот код.',
        }),
        {'childName': childName},
      );

  String get numericCodeLabel => _pick({
        'en': 'Numeric code',
        'ru': 'Числовой код',
      });

  String get tapToCopyLabel => _pick({
        'en': 'Tap to copy',
        'ru': 'Нажмите, чтобы скопировать',
      });

  String get inviteChildLabel => _pick({
        'en': 'Invite child',
        'ru': 'Пригласить ребёнка',
      });

  String get childCodeNoLoginPassword => _pick({
        'en':
            'The child phone no longer needs a login and password: just open the app and enter the code.',
        'ru':
            'На телефоне ребёнка теперь не нужен логин и пароль: достаточно открыть приложение и ввести код.',
      });

  String get locationTitle => _pick({
        'en': 'Location',
        'ru': 'Геолокация',
      });

  String get locationGrantedDescription => _pick({
        'en': 'Location access has been granted.',
        'ru': 'Доступ к геолокации выдан.',
      });

  String get locationNotGrantedDescription => _pick({
        'en': 'Location permission has not been granted yet.',
        'ru': 'Разрешение на геолокацию пока не выдано.',
      });

  String get locationServiceOffDescription => _pick({
        'en': 'Location services are currently turned off on this device.',
        'ru': 'Служба геолокации на устройстве сейчас выключена.',
      });

  String get grantAccessLabel => _pick({
        'en': 'Grant access',
        'ru': 'Выдать доступ',
      });

  String get backgroundLocationGrantedDescription => _pick({
        'en': 'Always allowed — location is sent even when the screen is off.',
        'ru':
            'Разрешено «Всегда» — местоположение отправляется даже при выключенном экране.',
      });

  String get backgroundLocationNeedAlwaysDescription => _pick({
        'en':
            'Without “Allow all the time”, Android stops sending coordinates when the screen turns off or the app is minimized. This is the main reason tracking seems to stop working.',
        'ru':
            'Без «Разрешить всегда» Android перестаёт присылать координаты, когда экран гаснет или приложение свёрнуто. Это главная причина, почему отслеживание «перестаёт работать».',
      });

  String get backgroundLocationNeedLocationFirst => _pick({
        'en':
            'First grant normal location permission, then enable “Allow all the time”.',
        'ru':
            'Сначала выдайте обычное разрешение на геолокацию, затем включите «Разрешить всегда».',
      });

  String get allowAllTheTimeLabel => _pick({
        'en': 'Allow all the time',
        'ru': 'Разрешить всегда',
      });

  String get microphoneGrantedDescription => _pick({
        'en': 'Microphone permission has already been granted.',
        'ru': 'Разрешение на микрофон уже выдано.',
      });

  String get microphoneNeededDescription => _pick({
        'en':
            'Without this permission, the Around feature will not be able to hear audio near the child.',
        'ru':
            'Без этого разрешения функция «Вокруг» не сможет слышать звук рядом с ребёнком.',
      });

  String get allowMicrophoneLabel => _pick({
        'en': 'Allow microphone',
        'ru': 'Разрешить микрофон',
      });

  String get notificationsGrantedDescription => _pick({
        'en': 'Notifications are allowed.',
        'ru': 'Уведомления разрешены.',
      });

  String get notificationsNeededDescription => _pick({
        'en':
            'Allow notifications so you do not miss commands and important events.',
        'ru':
            'Разрешите уведомления, чтобы не пропускать команды и важные события.',
      });

  String get allowNotificationsLabel => _pick({
        'en': 'Allow notifications',
        'ru': 'Разрешить уведомления',
      });

  String get usageAccessAlreadyGranted => _pick({
        'en': 'Access to app usage stats has already been granted.',
        'ru': 'Доступ к статистике приложений уже выдан.',
      });

  String get openSettingsLabel => _pick({
        'en': 'Open settings',
        'ru': 'Открыть настройки',
      });

  String get permissionStatusTitle => _pick({
        'en': 'Permission status',
        'ru': 'Статус разрешений',
      });

  String get checkingPermissionsStatus => _pick({
        'en': 'Checking which permissions are already enabled...',
        'ru': 'Проверяем, какие доступы уже включены...',
      });

  String grantedPermissionsCount(int granted, int total) => _fill(
        _pick({
          'en': 'Granted permissions: {granted} of {total}',
          'ru': 'Выдано разрешений: {granted} из {total}',
        }),
        {'granted': granted, 'total': total},
      );

  String get grantedLabel => _pick({
        'en': 'Granted',
        'ru': 'Выдано',
      });

  String get notGrantedLabel => _pick({
        'en': 'Not granted',
        'ru': 'Не выдано',
      });

  String get menuAppearsAfterAddingChild => _pick({
        'en': 'The menu will appear after you add a child',
        'ru': 'Меню появится после добавления ребёнка',
      });

  String get quickAccessLabel => _pick({
        'en': 'Quick access',
        'ru': 'Быстрый доступ',
      });

  String parentPanelLabel(String name) => _fill(
        _pick({
          'en': '{name} panel',
          'ru': 'Панель {name}',
        }),
        {'name': name},
      );

  String get selectedLabel => _pick({
        'en': 'Selected',
        'ru': 'Выбран',
      });

  String get onlineAroundSoundMenuTitle => _pick({
        'en': 'Live audio\naround child',
        'ru': 'Онлайн звук\nвокруг ребенка',
      });

  String get gameLimitsMenuTitle => _pick({
        'en': 'Game limits',
        'ru': 'Лимиты на игры',
      });

  String get incomingChatsMenuTitle => _pick({
        'en': 'Incoming chats',
        'ru': 'Входящие чаты',
      });

  String get mapPlacesMenuTitle => _pick({
        'en': 'Places on map',
        'ru': 'Места на карте',
      });

  String get movementHistoryMenuTitle => _pick({
        'en': 'Movement\nhistory',
        'ru': 'История\nпередвижения',
      });

  String get appStatsMenuTitle => _pick({
        'en': 'App\nstatistics',
        'ru': 'Статистика\nприложений',
      });

  String get childAchievementsMenuTitle => _pick({
        'en': 'Child\nachievements',
        'ru': 'Достижения\nребенка',
      });

  String get loudSignalMenuTitle => _pick({
        'en': 'Loud\nsignal',
        'ru': 'Громкий\nсигнал',
      });

  String get addChildFirstWarning => _pick({
        'en': 'Add a child first.',
        'ru': 'Сначала добавьте ребёнка.',
      });
}

extension SUiMoreExtras on S {
  String _pickMore(Map<String, String> values) =>
      pickLocalizedExtra(localeName, values);
  String _fillMore(String template, Map<String, Object> values) =>
      fillLocalizedExtra(template, values);

  String get okAction => _pickMore({
        'ar': 'حسناً',
        'az': 'Oldu',
        'de': 'OK',
        'en': 'OK',
        'es': 'OK',
        'fr': 'OK',
        'hy': 'Լավ',
        'it': 'OK',
        'ka': 'კარგი',
        'kk': 'OK',
        'ky': 'Макул',
        'pl': 'OK',
        'pt': 'OK',
        'ru': 'ОК',
        'tg': 'Хуб',
        'tk': 'Bolýar',
        'uz': 'OK',
      });

  String get signInAsParent => _pickMore({
        'ar': 'تسجيل الدخول كوالد',
        'az': 'Valideyn kimi daxil ol',
        'de': 'Als Elternteil anmelden',
        'en': 'Sign in as parent',
        'es': 'Iniciar sesión como padre',
        'fr': 'Se connecter en tant que parent',
        'hy': 'Մուտք գործել որպես ծնող',
        'it': 'Accedi come genitore',
        'ka': 'შესვლა როგორც მშობელი',
        'kk': 'Ата-ана ретінде кіру',
        'ky': 'Ата-эне катары кирүү',
        'pl': 'Zaloguj się jako rodzic',
        'pt': 'Entrar como responsável',
        'ru': 'Войти как родитель',
        'tg': 'Ҳамчун волид ворид шавед',
        'tk': 'Ene-ata hökmünde gir',
        'uz': 'Ota-ona sifatida kirish',
      });

  String get enterInviteCodeError => _pickMore({
        'ar': 'أدخل رمز الدعوة',
        'az': 'Dəvət kodunu daxil edin',
        'de': 'Gib den Einladungscode ein',
        'en': 'Enter the invite code',
        'es': 'Introduce el código de invitación',
        'fr': "Saisissez le code d'invitation",
        'hy': 'Մուտքագրեք հրավերի կոդը',
        'it': 'Inserisci il codice di invito',
        'ka': 'შეიყვანეთ მოსაწვევის კოდი',
        'kk': 'Шақыру кодын енгізіңіз',
        'ky': 'Чакыруу кодун киргизиңиз',
        'pl': 'Wpisz kod zaproszenia',
        'pt': 'Digite o código de convite',
        'ru': 'Введите код приглашения',
        'tg': 'Рамзи даъватро ворид кунед',
        'tk': 'Çakylyk koduny giriziň',
        'uz': 'Taklif kodini kiriting',
      });

  String get onlineAroundSoundMenuTitle => _pickMore({
        'en': 'Live audio\naround child',
        'ru': 'Онлайн звук\nвокруг ребенка',
      });

  String get gameLimitsMenuTitle => _pickMore({
        'en': 'Game limits',
        'ru': 'Лимиты на игры',
      });

  String get movementHistoryMenuTitle => _pickMore({
        'en': 'Movement\nhistory',
        'ru': 'История\nпередвижения',
      });

  String get childAchievementsMenuTitle => _pickMore({
        'en': 'Child\nachievements',
        'ru': 'Достижения\nребенка',
      });

  String get loudSignalMenuTitle => _pickMore({
        'en': 'Loud\nsignal',
        'ru': 'Громкий\nсигнал',
      });

  String get aroundSoundScreenTitle =>
      onlineAroundSoundMenuTitle.replaceAll('\n', ' ');

  String get movementHistoryScreenTitle =>
      movementHistoryMenuTitle.replaceAll('\n', ' ');

  String get achievementsScreenTitle =>
      childAchievementsMenuTitle.replaceAll('\n', ' ');

  String get loudSignalScreenTitle =>
      loudSignalMenuTitle.replaceAll('\n', ' ');

  String get signInAsParentCta => signInAsParent;

  String get sosNeedsHelpFallback => _pickMore({
        'en': 'needs help!',
        'ru': 'нуждается в помощи!',
      });

  String get parentLabel => _pickMore({
        'en': 'Parent',
        'ru': 'Родитель',
      });

  String get phoneOnline => _pickMore({
        'en': 'Phone is online',
        'ru': 'Телефон на связи',
      });

  String get phoneOffline => _pickMore({
        'en': 'Phone is offline',
        'ru': 'Телефон офлайн',
      });

  String get liveAudioCardTitle => _pickMore({
        'en': "Live audio from the child's phone",
        'ru': 'Онлайн аудио с телефона ребёнка',
      });

  String get tapToStartListeningAroundChild => _pickMore({
        'en': 'Tap the button below to start listening near the child.',
        'ru':
            'Нажмите кнопку ниже, чтобы начать непрерывно слушать звук рядом с ребёнком.',
      });

  String get startListeningLabel => _pickMore({
        'en': 'Start listening',
        'ru': 'Начать слушать',
      });

  String get stopListeningLabel => _pickMore({
        'en': 'Stop listening',
        'ru': 'Остановить прослушивание',
      });

  String get statusLabel => _pickMore({
        'en': 'Status',
        'ru': 'Статус',
      });

  String get onlineLabel => _pickMore({
        'en': 'Online',
        'ru': 'Онлайн',
      });

  String get offlineLabel => _pickMore({
        'en': 'Offline',
        'ru': 'Офлайн',
      });

  String get soundLabel => _pickMore({
        'en': 'Audio',
        'ru': 'Звук',
      });

  String get listeningNowLabel => _pickMore({
        'en': 'On',
        'ru': 'Идёт',
      });

  String get waitingLabel => _pickMore({
        'en': 'Waiting',
        'ru': 'Ждёт',
      });

  String get gameLimitsSubtitle => _pickMore({
        'en': 'Screen time and blocking controls',
        'ru': 'Управление экранным временем и блокировками',
      });

  String get limitsLabel => _pickMore({
        'en': 'Limits',
        'ru': 'Лимиты',
      });

  String get exceededLabel => _pickMore({
        'en': 'Exceeded',
        'ru': 'Превышено',
      });

  String get enableLimitLabel => _pickMore({
        'en': 'Enable limit',
        'ru': 'Включить лимит',
      });

  String limitWithValue(String value) => _fillMore(
        _pickMore({
          'en': 'Limit {value}',
          'ru': 'Лимит {value}',
        }),
        {'value': value},
      );

  String get editLimitLabel => _pickMore({
        'en': 'Edit limit',
        'ru': 'Изменить лимит',
      });

  String get unblockLabel => _pickMore({
        'en': 'Unblock',
        'ru': 'Разблокировать',
      });

  String formatCompactDuration(int minutes) {
    final normalized = minutes < 0 ? 0 : minutes;
    final hours = normalized ~/ 60;
    final remainingMinutes = normalized % 60;
    final isRu = localeName.toLowerCase().startsWith('ru');
    final minuteUnit = isRu ? 'м' : 'm';
    final hourUnit = isRu ? 'ч' : 'h';
    if (normalized == 0) return '0$minuteUnit';
    if (hours == 0) return '$remainingMinutes$minuteUnit';
    if (remainingMinutes == 0) return '$hours$hourUnit';
    return '$hours$hourUnit $remainingMinutes$minuteUnit';
  }

  String get achievementsHeroSubtitle => _pickMore({
        'en': 'Stars, tasks and available rewards',
        'ru': 'Звёзды, задачи и доступные награды',
      });

  String get earnedShortLabel => _pickMore({
        'en': 'earned',
        'ru': 'заработано',
      });

  String get balanceLabel => _pickMore({
        'en': 'Balance',
        'ru': 'Баланс',
      });

  String get waitingTasksLabel => _pickMore({
        'en': 'Waiting tasks',
        'ru': 'Задач ждёт',
      });

  String get tasksLabel => _pickMore({
        'en': 'Tasks',
        'ru': 'Задачи',
      });

  String get rewardsLabel => _pickMore({
        'en': 'Rewards',
        'ru': 'Награды',
      });

  String get noTasksYetLabel => _pickMore({
        'en': 'No tasks yet.',
        'ru': 'Пока задач нет.',
      });

  String get noRewardsYetLabel => _pickMore({
        'en': 'No rewards yet.',
        'ru': 'Пока наград нет.',
      });

  String completedAwaitingApproval(int count) => _fillMore(
        _pickMore({
          'en': 'Completed, waiting for approval: {count}',
          'ru': 'Выполнено, ждёт подтверждения: {count}',
        }),
        {'count': count},
      );

  String get taskInProgressLabel => _pickMore({
        'en': 'In progress',
        'ru': 'В процессе',
      });

  String starsAmountLabel(int count) => _fillMore(
        _pickMore({
          'en': '+{count} stars',
          'ru': '+{count} звёзд',
        }),
        {'count': count},
      );

  String achievedOn(String date) => _fillMore(
        _pickMore({
          'en': 'Achieved {date}',
          'ru': 'Достигнуто {date}',
        }),
        {'date': date},
      );

  String get achievedLabel => _pickMore({
        'en': 'Achieved',
        'ru': 'Достигнуто',
      });

  String get availableLabel => _pickMore({
        'en': 'Available',
        'ru': 'Доступна',
      });

  String get loudSignalStoppedLabel => _pickMore({
        'en': 'Loud signal stopped.',
        'ru': 'Громкий сигнал остановлен.',
      });

  String get loudSignalActiveSubtitle => _pickMore({
        'en': 'A loud signal is currently playing on the device',
        'ru': 'Сейчас на устройстве включён громкий сигнал',
      });

  String get loudSignalInactiveSubtitle => _pickMore({
        'en': 'Send a signal so the child can quickly find the phone',
        'ru': 'Отправьте сигнал, чтобы ребёнок быстро нашёл телефон',
      });

  String get connectionLabel => _pickMore({
        'en': 'Connection',
        'ru': 'Связь',
      });

  String get batteryLabel => _pickMore({
        'en': 'Battery',
        'ru': 'Батарея',
      });

  String get signalAlreadySentLabel => _pickMore({
        'en': 'Signal already sent',
        'ru': 'Сигнал уже отправлен',
      });

  String get sendLoudSignalLabel => _pickMore({
        'en': 'Send loud sound signal',
        'ru': 'Отправить громкий звуковой сигнал',
      });

  String get stopSignalHint => _pickMore({
        'en': 'If the child already found the phone, you can stop the signal.',
        'ru':
            'Если ребёнок уже нашёл телефон, вы можете сразу остановить сигнал.',
      });

  String get sendSignalHint => _pickMore({
        'en':
            'Helpful when the phone is nearby, but out of sight or in silent mode.',
        'ru':
            'Полезно, когда телефон рядом, но его не видно или он в беззвучном режиме.',
      });

  String get stopSignalLabel => _pickMore({
        'en': 'Stop signal',
        'ru': 'Остановить сигнал',
      });

  String get startSignalLabel => _pickMore({
        'en': 'Enable signal',
        'ru': 'Включить сигнал',
      });

  String get yesterdayLabel => _pickMore({
        'en': 'Yesterday',
        'ru': 'Вчера',
      });

  String get last7DaysLabel => _pickMore({
        'en': '7 days',
        'ru': '7 дней',
      });

  String get noMovementDataForPeriod => _pickMore({
        'en': 'No movement data for the selected period yet.',
        'ru': 'Пока нет данных о передвижениях за выбранный период.',
      });
}

extension SExtras on S {
  String _pick(Map<String, String> values) =>
      pickLocalizedExtra(localeName, values);
  String _fill(String template, Map<String, Object> values) =>
      fillLocalizedExtra(template, values);

  String get appLabel => _pick({
        'ar': 'التطبيق',
        'az': 'Tətbiq',
        'de': 'App',
        'en': 'App',
        'es': 'App',
        'fr': 'Appli',
        'hy': 'Հավելված',
        'it': 'App',
        'ka': 'აპი',
        'kk': 'Қосымша',
        'ky': 'Колдонмо',
        'pl': 'Aplikacja',
        'pt': 'App',
        'ru': 'Приложение',
        'tg': 'Барнома',
        'tk': 'Programma',
        'uz': 'Ilova',
      });

  String get childLabel => _pick({
        'ar': 'الطفل',
        'az': 'Uşaq',
        'de': 'Kind',
        'en': 'Child',
        'es': 'Niño',
        'fr': 'Enfant',
        'hy': 'Երեխա',
        'it': 'Bambino',
        'ka': 'ბავშვი',
        'kk': 'Бала',
        'ky': 'Бала',
        'pl': 'Dziecko',
        'pt': 'Criança',
        'ru': 'Ребёнок',
        'tg': 'Кӯдак',
        'tk': 'Çaga',
        'uz': 'Bola',
      });

  String get friendLabel => _pick({
        'ar': 'صديق',
        'az': 'dost',
        'de': 'Freund',
        'en': 'friend',
        'es': 'amigo',
        'fr': 'ami',
        'hy': 'ընկեր',
        'it': 'amico',
        'ka': 'მეგობარო',
        'kk': 'дос',
        'ky': 'дос',
        'pl': 'przyjaciel',
        'pt': 'amigo',
        'ru': 'друг',
        'tg': 'дӯст',
        'tk': 'dost',
        'uz': 'do‘st',
      });

  String get meLabel => _pick({
        'ar': 'أنا',
        'az': 'Mən',
        'de': 'Ich',
        'en': 'Me',
        'es': 'Yo',
        'fr': 'Moi',
        'hy': 'Ես',
        'it': 'Io',
        'ka': 'მე',
        'kk': 'Мен',
        'ky': 'Мен',
        'pl': 'Ja',
        'pt': 'Eu',
        'ru': 'Я',
        'tg': 'Ман',
        'tk': 'Men',
        'uz': 'Men',
      });

  String get chargingShort => _pick({
        'ar': 'قيد الشحن',
        'az': 'Şarj olur',
        'de': 'Lädt',
        'en': 'Charging',
        'es': 'Cargando',
        'fr': 'En charge',
        'hy': 'Լիցքավորվում է',
        'it': 'In carica',
        'ka': 'იტენება',
        'kk': 'Зарядталып жатыр',
        'ky': 'Кубатталууда',
        'pl': 'Ładuje się',
        'pt': 'Carregando',
        'ru': 'На зарядке',
        'tg': 'Пур шуда истодааст',
        'tk': 'Zarýad alýar',
        'uz': 'Quvvatlanmoqda',
      });

  String get notChargingShort => _pick({
        'ar': 'غير قيد الشحن',
        'az': 'Şarj olunmur',
        'de': 'Lädt nicht',
        'en': 'Not charging',
        'es': 'Sin carga',
        'fr': 'Ne charge pas',
        'hy': 'Չի լիցքավորվում',
        'it': 'Non in carica',
        'ka': 'არ იტენება',
        'kk': 'Зарядталмайды',
        'ky': 'Кубатталбай жатат',
        'pl': 'Nie ładuje się',
        'pt': 'Sem carregamento',
        'ru': 'Не заряжается',
        'tg': 'Пур намешавад',
        'tk': 'Zarýad almaýar',
        'uz': 'Quvvatlanmayapti',
      });

  String get deviceIsCharging => _pick({
        'ar': 'الجهاز قيد الشحن',
        'az': 'Cihaz şarj olur',
        'de': 'Gerät wird geladen',
        'en': 'Device is charging',
        'es': 'El dispositivo se está cargando',
        'fr': "L'appareil est en charge",
        'hy': 'Սարքը լիցքավորվում է',
        'it': 'Il dispositivo è in carica',
        'ka': 'მოწყობილობა იტენება',
        'kk': 'Құрылғы зарядталып жатыр',
        'ky': 'Түзмөк кубатталууда',
        'pl': 'Urządzenie się ładuje',
        'pt': 'O dispositivo está carregando',
        'ru': 'Устройство на зарядке',
        'tg': 'Дастгоҳ пур шуда истодааст',
        'tk': 'Enjam zarýad alýar',
        'uz': 'Qurilma quvvatlanmoqda',
      });

  String get deviceIsNotCharging => _pick({
        'ar': 'الجهاز غير قيد الشحن',
        'az': 'Cihaz şarj olunmur',
        'de': 'Gerät lädt nicht',
        'en': 'Device is not charging',
        'es': 'El dispositivo no se está cargando',
        'fr': "L'appareil ne charge pas",
        'hy': 'Սարքը չի լիցքավորվում',
        'it': 'Il dispositivo non è in carica',
        'ka': 'მოწყობილობა არ იტენება',
        'kk': 'Құрылғы зарядталмайды',
        'ky': 'Түзмөк кубатталбай жатат',
        'pl': 'Urządzenie się nie ładuje',
        'pt': 'O dispositivo não está carregando',
        'ru': 'Устройство не заряжается',
        'tg': 'Дастгоҳ пур намешавад',
        'tk': 'Enjam zarýad almaýar',
        'uz': 'Qurilma quvvatlanmayapti',
      });

  String get noAdditionalAppsToAdd => _pick({
        'ar': 'لا توجد تطبيقات إضافية لإضافتها',
        'az': 'Əlavə ediləcək başqa tətbiq yoxdur',
        'de': 'Keine weiteren Apps zum Hinzufügen',
        'en': 'No additional apps to add',
        'es': 'No hay aplicaciones adicionales para agregar',
        'fr': "Aucune application supplémentaire à ajouter",
        'hy': 'Ավելացնելու այլ հավելվածներ չկան',
        'it': 'Nessuna altra app da aggiungere',
        'ka': 'დასამატებელი სხვა აპები არ არის',
        'kk': 'Қосатын қосымша қолданбалар жоқ',
        'ky': 'Кошо турган кошумча колдонмолор жок',
        'pl': 'Brak dodatkowych aplikacji do dodania',
        'pt': 'Nenhum aplicativo adicional para adicionar',
        'ru': 'Нет дополнительных приложений для добавления',
        'tg': 'Барномаҳои иловагӣ барои илова кардан нестанд',
        'tk': 'Goşuljak goşmaça programma ýok',
        'uz': 'Qo‘shish uchun qo‘shimcha ilovalar yo‘q',
      });

  String get addApp => _pick({
        'ar': 'إضافة تطبيق',
        'az': 'Tətbiq əlavə et',
        'de': 'App hinzufügen',
        'en': 'Add App',
        'es': 'Agregar aplicación',
        'fr': 'Ajouter une appli',
        'hy': 'Ավելացնել հավելված',
        'it': 'Aggiungi app',
        'ka': 'აპის დამატება',
        'kk': 'Қолданба қосу',
        'ky': 'Колдонмо кошуу',
        'pl': 'Dodaj aplikację',
        'pt': 'Adicionar app',
        'ru': 'Добавить приложение',
        'tg': 'Илова кардани барнома',
        'tk': 'Programma goş',
        'uz': 'Ilova qo‘shish',
      });

  String get add => _pick({
        'ar': 'إضافة',
        'az': 'Əlavə et',
        'de': 'Hinzufügen',
        'en': 'Add',
        'es': 'Agregar',
        'fr': 'Ajouter',
        'hy': 'Ավելացնել',
        'it': 'Aggiungi',
        'ka': 'დამატება',
        'kk': 'Қосу',
        'ky': 'Кошуу',
        'pl': 'Dodaj',
        'pt': 'Adicionar',
        'ru': 'Добавить',
        'tg': 'Илова',
        'tk': 'Goş',
        'uz': 'Qo‘shish',
      });

  String get searchPlaceholder => _pick({
        'ar': 'بحث...',
        'az': 'Axtar...',
        'de': 'Suchen...',
        'en': 'Search...',
        'es': 'Buscar...',
        'fr': 'Rechercher...',
        'hy': 'Որոնել...',
        'it': 'Cerca...',
        'ka': 'ძებნა...',
        'kk': 'Іздеу...',
        'ky': 'Издөө...',
        'pl': 'Szukaj...',
        'pt': 'Pesquisar...',
        'ru': 'Поиск...',
        'tg': 'Ҷустуҷӯ...',
        'tk': 'Gözle...',
        'uz': 'Qidirish...',
      });

  String get appBlockingTitle => _pick({
        'en': 'App blocking',
        'ru': 'Блокировка приложений',
      });

  String get appBlockingHeadline => _pick({
        'en': 'Choose which apps should feel locked on this device.',
        'ru':
            'Выберите, какие приложения должны ощущаться как заблокированные на этом устройстве.',
      });

  String get appBlockingDescription => _pick({
        'en':
            'When a blocked app opens, Family Security immediately closes it and shows a blocking screen through Android Accessibility Service.',
        'ru':
            'Когда заблокированное приложение открывается, Family Security сразу закрывает его и показывает экран блокировки через службу специальных возможностей Android.',
      });

  String get appBlockingUnsupported => _pick({
        'en': 'App blocking setup is available only on Android devices.',
        'ru':
            'Настройка блокировки приложений доступна только на Android-устройствах.',
      });

  String get noAppsFound => _pick({
        'en': 'No apps found for this search.',
        'ru': 'По этому запросу приложения не найдены.',
      });

  String get statusEnabled => _pick({
        'en': 'Enabled',
        'ru': 'Включено',
      });

  String get statusNeeded => _pick({
        'en': 'Action needed',
        'ru': 'Нужно действие',
      });

  String get optionalLabel => _pick({
        'en': 'Optional',
        'ru': 'Необязательно',
      });

  String get openAccessibilitySettingsLabel => _pick({
        'en': 'Open accessibility settings',
        'ru': 'Открыть настройки специальных возможностей',
      });

  String limitAddedForApp(String appName) => _fill(
        _pick({
          'ar': 'تمت إضافة حد للتطبيق {appName}',
          'az': '{appName} üçün limit əlavə edildi',
          'de': 'Limit für {appName} hinzugefügt',
          'en': 'Limit added for {appName}',
          'es': 'Límite agregado para {appName}',
          'fr': 'Limite ajoutée pour {appName}',
          'hy': '{appName}-ի համար սահմանաչափ է ավելացվել',
          'it': 'Limite aggiunto per {appName}',
          'ka': 'ლიმიტი დაემატა: {appName}',
          'kk': '{appName} үшін лимит қосылды',
          'ky': '{appName} үчүн чектөө кошулду',
          'pl': 'Dodano limit dla {appName}',
          'pt': 'Limite adicionado para {appName}',
          'ru': 'Лимит добавлен для {appName}',
          'tg': 'Барои {appName} маҳдудият илова шуд',
          'tk': '{appName} üçin çäk goşuldy',
          'uz': '{appName} uchun limit qo‘shildi',
        }),
        {'appName': appName},
      );

  String appBlocked(String appName) => _fill(
        _pick({
          'ar': 'تم حظر {appName}',
          'az': '{appName} bloklandı',
          'de': '{appName} blockiert',
          'en': '{appName} blocked',
          'es': '{appName} bloqueado',
          'fr': '{appName} bloqué',
          'hy': '{appName}-ը արգելափակվեց',
          'it': '{appName} bloccata',
          'ka': '{appName} დაიბლოკა',
          'kk': '{appName} бұғатталды',
          'ky': '{appName} бөгөттөлдү',
          'pl': '{appName} zablokowano',
          'pt': '{appName} bloqueado',
          'ru': '{appName} заблокировано',
          'tg': '{appName} масдуд шуд',
          'tk': '{appName} bloklandy',
          'uz': '{appName} bloklandi',
        }),
        {'appName': appName},
      );

  String appUnblocked(String appName) => _fill(
        _pick({
          'ar': 'تم إلغاء حظر {appName}',
          'az': '{appName} blokdan çıxarıldı',
          'de': '{appName} entsperrt',
          'en': '{appName} unblocked',
          'es': 'Se desbloqueó {appName}',
          'fr': '{appName} débloqué',
          'hy': '{appName}-ի արգելափակումը հանվեց',
          'it': '{appName} sbloccata',
          'ka': '{appName} განიბლოკა',
          'kk': '{appName} бұғаттан шығарылды',
          'ky': '{appName} бөгөттөн чыгарылды',
          'pl': 'Odblokowano {appName}',
          'pt': '{appName} desbloqueado',
          'ru': '{appName} разблокировано',
          'tg': '{appName} аз масдуд бароварда шуд',
          'tk': '{appName} blokdan çykaryldy',
          'uz': '{appName} blokdan chiqarildi',
        }),
        {'appName': appName},
      );

  String get selectedDay => _pick({
        'ar': 'اليوم المحدد',
        'az': 'Seçilmiş gün',
        'de': 'Ausgewählter Tag',
        'en': 'Selected day',
        'es': 'Día seleccionado',
        'fr': 'Jour sélectionné',
        'hy': 'Ընտրված օր',
        'it': 'Giorno selezionato',
        'ka': 'არჩეული დღე',
        'kk': 'Таңдалған күн',
        'ky': 'Тандалган күн',
        'pl': 'Wybrany dzień',
        'pt': 'Dia selecionado',
        'ru': 'Выбранный день',
        'tg': 'Рӯзи интихобшуда',
        'tk': 'Saýlanan gün',
        'uz': 'Tanlangan kun',
      });

  String get hasData => _pick({
        'ar': 'توجد بيانات',
        'az': 'Məlumat var',
        'de': 'Hat Daten',
        'en': 'Has data',
        'es': 'Tiene datos',
        'fr': 'Données disponibles',
        'hy': 'Կան տվյալներ',
        'it': 'Con dati',
        'ka': 'მონაცემები არის',
        'kk': 'Дерек бар',
        'ky': 'Маалымат бар',
        'pl': 'Ma dane',
        'pt': 'Tem dados',
        'ru': 'Есть данные',
        'tg': 'Маълумот ҳаст',
        'tk': 'Maglumat bar',
        'uz': 'Ma’lumot bor',
      });

  String noStatisticsFoundFor(String date) => _fill(
        _pick({
          'ar': 'لم يتم العثور على إحصاءات بتاريخ {date}.',
          'az': '{date} üçün statistika tapılmadı.',
          'de': 'Keine Statistiken für {date} gefunden.',
          'en': 'No statistics found for {date}.',
          'es': 'No se encontraron estadísticas para {date}.',
          'fr': 'Aucune statistique trouvée pour {date}.',
          'hy': '{date}-ի համար վիճակագրություն չի գտնվել։',
          'it': 'Nessuna statistica trovata per {date}.',
          'ka': '{date}-ისთვის სტატისტიკა ვერ მოიძებნა.',
          'kk': '{date} күніне статистика табылмады.',
          'ky': '{date} үчүн статистика табылган жок.',
          'pl': 'Nie znaleziono statystyk dla {date}.',
          'pt': 'Nenhuma estatística encontrada para {date}.',
          'ru': 'За {date} статистика не найдена.',
          'tg': 'Барои {date} омор ёфт нашуд.',
          'tk': '{date} üçin statistika tapylmady.',
          'uz': '{date} uchun statistika topilmadi.',
        }),
        {'date': date},
      );

  String get noData => _pick({
        'ar': 'لا توجد بيانات',
        'az': 'Məlumat yoxdur',
        'de': 'Keine Daten',
        'en': 'No data',
        'es': 'Sin datos',
        'fr': 'Aucune donnée',
        'hy': 'Տվյալներ չկան',
        'it': 'Nessun dato',
        'ka': 'მონაცემები არ არის',
        'kk': 'Дерек жоқ',
        'ky': 'Маалымат жок',
        'pl': 'Brak danych',
        'pt': 'Sem dados',
        'ru': 'Данных нет',
        'tg': 'Маълумот нест',
        'tk': 'Maglumat ýok',
        'uz': 'Ma’lumot yo‘q',
      });

  String get block => _pick({
        'ar': 'حظر',
        'az': 'Blokla',
        'de': 'Sperren',
        'en': 'Block',
        'es': 'Bloquear',
        'fr': 'Bloquer',
        'hy': 'Արգելափակել',
        'it': 'Blocca',
        'ka': 'დაბლოკვა',
        'kk': 'Бұғаттау',
        'ky': 'Бөгөттөө',
        'pl': 'Zablokuj',
        'pt': 'Bloquear',
        'ru': 'Блок',
        'tg': 'Масдуд кардан',
        'tk': 'Blokla',
        'uz': 'Bloklash',
      });

  String get blocked => _pick({
        'ar': 'محظور',
        'az': 'Bloklanıb',
        'de': 'Blockiert',
        'en': 'Blocked',
        'es': 'Bloqueado',
        'fr': 'Bloqué',
        'hy': 'Արգելափակված',
        'it': 'Bloccata',
        'ka': 'დაბლოკილია',
        'kk': 'Бұғатталған',
        'ky': 'Бөгөттөлгөн',
        'pl': 'Zablokowano',
        'pt': 'Bloqueado',
        'ru': 'Заблокировано',
        'tg': 'Масдуд',
        'tk': 'Bloklanan',
        'uz': 'Bloklangan',
      });

  String loudSignalSent(String childName) => _fill(
        _pick({
          'ar': 'تم إرسال الإشارة العالية إلى {childName}',
          'az': 'Yüksək siqnal {childName} cihazına göndərildi',
          'de': 'Lautes Signal an {childName} gesendet',
          'en': 'Loud signal sent to {childName}',
          'es': 'Se envió una señal sonora a {childName}',
          'fr': 'Signal sonore envoyé à {childName}',
          'hy': 'Բարձր ազդանշանը ուղարկվել է {childName}-ին',
          'it': 'Segnale forte inviato a {childName}',
          'ka': 'ხმამაღალი სიგნალი გაეგზავნა {childName}-ს',
          'kk': 'Қатты дыбыс сигналы {childName} құрылғысына жіберілді',
          'ky': 'Катуу сигнал {childName} түзмөгүнө жөнөтүлдү',
          'pl': 'Wysłano głośny sygnał do {childName}',
          'pt': 'Sinal sonoro enviado para {childName}',
          'ru': 'Громкий сигнал отправлен {childName}',
          'tg': 'Сигнали баланд ба {childName} фиристода шуд',
          'tk': 'Gaty sesli signal {childName} enjamyna ugradyldy',
          'uz': 'Baland signal {childName} qurilmasiga yuborildi',
        }),
        {'childName': childName},
      );

  String get couldNotCreateLiveSession => _pick({
        'ar': 'تعذر إنشاء جلسة مباشرة',
        'az': 'Canlı sessiya yaradıla bilmədi',
        'de': 'Live-Sitzung konnte nicht erstellt werden',
        'en': 'Could not create a live session',
        'es': 'No se pudo crear una sesión en vivo',
        'fr': 'Impossible de créer une session en direct',
        'hy': 'Չհաջողվեց ստեղծել ուղիղ սեսիա',
        'it': 'Impossibile creare una sessione live',
        'ka': 'ვერ შეიქმნა live-სესია',
        'kk': 'Тікелей сессияны құру мүмкін болмады',
        'ky': 'Түз эфир сессиясын түзүү мүмкүн болгон жок',
        'pl': 'Nie udało się utworzyć sesji na żywo',
        'pt': 'Não foi possível criar uma sessão ao vivo',
        'ru': 'Не удалось создать live-сессию',
        'tg': 'Сессияи зинда сохта нашуд',
        'tk': 'Göni sessiýany döretmek başartmady',
        'uz': 'Jonli sessiyani yaratib bo‘lmadi',
      });

  String get stopAction => _pick({
        'ar': 'إيقاف',
        'az': 'DAYAN',
        'de': 'STOP',
        'en': 'STOP',
        'es': 'DETENER',
        'fr': 'STOP',
        'hy': 'ԿԱՆԳ',
        'it': 'STOP',
        'ka': 'სტოპ',
        'kk': 'ТОҚТАТУ',
        'ky': 'ТОКТОТ',
        'pl': 'STOP',
        'pt': 'PARAR',
        'ru': 'СТОП',
        'tg': 'ИСТ',
        'tk': 'STOP',
        'uz': 'TO‘XTAT',
      });

  String get connectingToChildPhone => _pick({
        'ar': 'جارٍ الاتصال بهاتف الطفل...',
        'az': 'Uşağın telefonuna qoşulur...',
        'de': 'Verbindung zum Telefon des Kindes wird hergestellt...',
        'en': "Connecting to the child's phone...",
        'es': 'Conectando al teléfono del niño...',
        'fr': "Connexion au téléphone de l'enfant...",
        'hy': 'Միացվում է երեխայի հեռախոսին...',
        'it': 'Connessione al telefono del bambino...',
        'ka': 'ბავშვის ტელეფონთან დაკავშირება...',
        'kk': 'Баланың телефонына қосылып жатыр...',
        'ky': 'Баланын телефонуна туташууда...',
        'pl': 'Łączenie z telefonem dziecka...',
        'pt': 'Conectando ao telefone da criança...',
        'ru': 'Подключаемся к телефону ребёнка...',
        'tg': 'Ба телефони кӯдак пайваст шуда истодааст...',
        'tk': 'Çaganyň telefonyna birikdirilýär...',
        'uz': 'Bolaning telefoniga ulanmoqda...',
      });

  String get waitingForFirstAudioClip => _pick({
        'ar': 'ننتظر أول مقطع صوتي...',
        'az': 'İlk audio fraqment gözlənilir...',
        'de': 'Warte auf den ersten Audioclip...',
        'en': 'Waiting for the first audio clip...',
        'es': 'Esperando el primer clip de audio...',
        'fr': 'En attente du premier extrait audio...',
        'hy': 'Սպասում ենք առաջին ձայնային հատվածին...',
        'it': 'In attesa del primo clip audio...',
        'ka': 'ველოდებით პირველ აუდიო ფრაგმენტს...',
        'kk': 'Алғашқы аудио үзінді күтілуде...',
        'ky': 'Биринчи аудио үзүндү күтүлүүдө...',
        'pl': 'Oczekiwanie na pierwszy klip audio...',
        'pt': 'Aguardando o primeiro clipe de áudio...',
        'ru': 'Ждём первый аудио-фрагмент...',
        'tg': 'Пораи аввалини аудио интизор аст...',
        'tk': 'Ilkinji ses bölegi garaşylýar...',
        'uz': 'Birinchi audio bo‘lagi kutilmoqda...',
      });

  String listeningTo(String childName) => _fill(
        _pick({
          'ar': 'الاستماع إلى {childName}',
          'az': '{childName} dinlənilir',
          'de': 'Höre {childName} zu',
          'en': 'Listening to {childName}',
          'es': 'Escuchando a {childName}',
          'fr': 'Écoute de {childName}',
          'hy': 'Լսում ենք {childName}-ին',
          'it': 'In ascolto di {childName}',
          'ka': '{childName}-ის მოსმენა',
          'kk': '{childName} тыңдалып жатыр',
          'ky': '{childName} угулуп жатат',
          'pl': 'Nasłuchiwanie: {childName}',
          'pt': 'Ouvindo {childName}',
          'ru': 'Слушаю {childName}',
          'tg': 'Гӯш кардан ба {childName}',
          'tk': '{childName} diňlenýär',
          'uz': '{childName} tinglanmoqda',
        }),
        {'childName': childName},
      );

  String get errorLabel => _pick({
        'ar': 'خطأ',
        'az': 'Xəta',
        'de': 'Fehler',
        'en': 'Error',
        'es': 'Error',
        'fr': 'Erreur',
        'hy': 'Սխալ',
        'it': 'Errore',
        'ka': 'შეცდომა',
        'kk': 'Қате',
        'ky': 'Ката',
        'pl': 'Błąd',
        'pt': 'Erro',
        'ru': 'Ошибка',
        'tg': 'Хато',
        'tk': 'Ýalňyşlyk',
        'uz': 'Xato',
      });

  String get aroundAudioInfo => _pick({
        'ar':
            'يصل الصوت المباشر على شكل مقاطع صوتية قصيرة عبر خدمة الخلفية لدى الطفل. هذا أكثر موثوقية ولا يتجمد مثل WebRTC.',
        'az':
            'Canlı səs uşağın fon xidməti vasitəsilə qısa audio fraqmentlərlə gəlir. Bu daha etibarlıdır və WebRTC kimi donmur.',
        'de':
            'Der Live-Ton kommt als kurze Audioclips über den Hintergrunddienst des Kindes. Das ist zuverlässiger und hängt nicht wie WebRTC.',
        'en':
            'Live audio comes through the child background service in short clips. This is more reliable and does not freeze like WebRTC.',
        'es':
            'El audio en vivo llega en clips cortos a través del servicio en segundo plano del niño. Es más fiable y no se congela como WebRTC.',
        'fr':
            "L'audio en direct arrive par courts extraits via le service en arrière-plan de l'enfant. C'est plus fiable et ne se bloque pas comme WebRTC.",
        'hy':
            'Կենդանի ձայնը գալիս է կարճ աուդիոհատվածներով երեխայի ֆոնային ծառայության միջոցով։ Սա ավելի հուսալի է և չի կախվում WebRTC-ի նման։',
        'it':
            'L’audio in diretta arriva in brevi clip tramite il servizio in background del bambino. È più affidabile e non si blocca come WebRTC.',
        'ka':
            'ცოცხალი ხმა მოდის მოკლე აუდიო ფრაგმენტებით ბავშვის ფონური სერვისის მეშვეობით. ეს უფრო საიმედოა და WebRTC-სავით არ ჭედავს.',
        'kk':
            'Тікелей дыбыс баланың фондық қызметі арқылы қысқа аудио үзінділермен келеді. Бұл сенімдірек және WebRTC сияқты тұрып қалмайды.',
        'ky':
            'Түз эфирдеги үн баланын фондук кызматы аркылуу кыска аудио үзүндүлөр менен келет. Бул ишенимдүүрөөк жана WebRTC сыяктуу тыгылып калбайт.',
        'pl':
            'Dźwięk na żywo dociera w krótkich klipach przez usługę działającą w tle na urządzeniu dziecka. To bardziej niezawodne i nie zawiesza się jak WebRTC.',
        'pt':
            'O áudio ao vivo chega em clipes curtos pelo serviço em segundo plano da criança. É mais confiável e não trava como o WebRTC.',
        'ru':
            'Живой звук идёт короткими аудио-фрагментами через фоновый сервис ребёнка. Это надёжнее и не зависает на WebRTC.',
        'tg':
            'Садои зинда бо пораҳои кӯтоҳи аудио тавассути хидмати пасзаминаи кӯдак мерасад. Ин боэътимодтар аст ва мисли WebRTC овезон намешавад.',
        'tk':
            'Göni ses çaganyň fon hyzmaty arkaly gysga ses bölekleri görnüşinde gelýär. Bu has ygtybarly we WebRTC ýaly doňmaýar.',
        'uz':
            'Jonli audio bolaning fon xizmati orqali qisqa audio bo‘laklarda keladi. Bu ishonchliroq va WebRTC kabi qotib qolmaydi.',
      });

  String get resolvingAddress => _pick({
        'ar': 'جارٍ تحديد العنوان...',
        'az': 'Ünvan dəqiqləşdirilir...',
        'de': 'Adresse wird ermittelt...',
        'en': 'Resolving address...',
        'es': 'Resolviendo dirección...',
        'fr': "Recherche de l'adresse...",
        'hy': 'Հասցեն ճշգրտվում է...',
        'it': 'Risoluzione indirizzo...',
        'ka': 'მისამართი ზუსტდება...',
        'kk': 'Мекенжай анықталып жатыр...',
        'ky': 'Дарек такталып жатат...',
        'pl': 'Ustalanie adresu...',
        'pt': 'Obtendo endereço...',
        'ru': 'Адрес уточняется...',
        'tg': 'Нишонӣ муайян мешавад...',
        'tk': 'Salgysy anyklanýar...',
        'uz': 'Manzil aniqlanmoqda...',
      });

  String get enableAccessibilityService => _pick({
        'ar': 'فعّل خدمة إمكانية الوصول',
        'az': 'Əlçatanlıq xidmətini aktiv edin',
        'de': 'Bedienungshilfe aktivieren',
        'en': 'Enable accessibility service',
        'es': 'Activa el servicio de accesibilidad',
        'fr': "Activer le service d'accessibilité",
        'hy': 'Միացրեք հասանելիության ծառայությունը',
        'it': 'Abilita il servizio di accessibilità',
        'ka': 'ჩართეთ ხელმისაწვდომობის სერვისი',
        'kk': 'Арнайы мүмкіндіктер қызметін қосыңыз',
        'ky': 'Атайын мүмкүнчүлүктөр кызматын күйгүзүңүз',
        'pl': 'Włącz usługę ułatwień dostępu',
        'pt': 'Ative o serviço de acessibilidade',
        'ru': 'Включите службу специальных возможностей',
        'tg': 'Хидмати дастрасиро фаъол кунед',
        'tk': 'Elýeterlilik hyzmatyny işlediň',
        'uz': 'Maxsus imkoniyatlar xizmatini yoqing',
      });

  String get accessibilityServiceDescription => _pick({
        'ar':
            'بدون هذا الإذن ستظل التطبيقات التي حظرها الوالد تُفتح. ابحث عن "Family Security — App Blocking" في القائمة وفعّله.',
        'az':
            'Bu icazə olmadan valideynin blokladığı tətbiqlər yenə də açılacaq. Siyahıda "Family Security — App Blocking" xidmətini tapın və aktiv edin.',
        'de':
            'Ohne diese Berechtigung lassen sich von den Eltern blockierte Apps weiterhin öffnen. Suche in der Liste nach „Family Security — App Blocking“ und aktiviere es.',
        'en':
            'Without this permission, apps blocked by the parent will still open. Find "Family Security — App Blocking" in the list and enable it.',
        'es':
            'Sin este permiso, las apps bloqueadas por el padre seguirán abriéndose. Busca "Family Security — App Blocking" en la lista y actívalo.',
        'fr':
            'Sans cette autorisation, les applications bloquées par le parent pourront toujours être ouvertes. Trouvez "Family Security — App Blocking" dans la liste et activez-le.',
        'hy':
            'Առանց այս թույլտվության ծնողի կողմից արգելափակված հավելվածները կբացվեն։ Ցանկում գտեք «Family Security — App Blocking»-ը և միացրեք այն։',
        'it':
            'Senza questa autorizzazione, le app bloccate dal genitore continueranno ad aprirsi. Trova "Family Security — App Blocking" nell’elenco e abilitalo.',
        'ka':
            'ამ ნებართვის გარეშე მშობლის მიერ დაბლოკილი აპები მაინც გაიხსნება. სიაში იპოვეთ "Family Security — App Blocking" და ჩართეთ.',
        'kk':
            'Бұл рұқсатсыз ата-ана бұғаттаған қолданбалар бәрібір ашылады. Тізімнен "Family Security — App Blocking" қызметін тауып, қосыңыз.',
        'ky':
            'Бул уруксат болбосо, ата-эне бөгөттөгөн колдонмолор баары бир ачылат. Тизмеден "Family Security — App Blocking" кызматын таап, күйгүзүңүз.',
        'pl':
            'Bez tego uprawnienia aplikacje zablokowane przez rodzica nadal będą się otwierać. Znajdź na liście „Family Security — App Blocking” i włącz tę usługę.',
        'pt':
            'Sem esta permissão, os apps bloqueados pelo responsável ainda serão abertos. Encontre "Family Security — App Blocking" na lista e ative-o.',
        'ru':
            'Без этого разрешения заблокированные родителем приложения будут открываться. Найдите «Family Security — блокировка приложений» в списке и включите её.',
        'tg':
            'Бе ин иҷозат барномаҳое, ки аз ҷониби волид баста шудаанд, ҳамоно кушода мешаванд. Дар рӯйхат "Family Security — App Blocking"-ро ёфта, фаъол кунед.',
        'tk':
            'Bu rugsat bolmasa, ene-atanyň bloklan programmalary şonda-da açylar. Sanawdan "Family Security — App Blocking" hyzmatyny tapyp işlediň.',
        'uz':
            'Bu ruxsatsiz ota-ona bloklagan ilovalar baribir ochiladi. Ro‘yxatdan "Family Security — App Blocking" xizmatini topib yoqing.',
      });

  String get allowLocationAllTheTime => _pick({
        'ar': 'اسمح بالموقع طوال الوقت',
        'az': 'Məkanı hər zaman icazə verin',
        'de': 'Standort immer erlauben',
        'en': 'Allow location all the time',
        'es': 'Permitir ubicación todo el tiempo',
        'fr': 'Autoriser la localisation en permanence',
        'hy': 'Թույլատրել տեղադրությունը միշտ',
        'it': 'Consenti la posizione sempre',
        'ka': 'მდებარეობა ყოველთვის დაუშვი',
        'kk': 'Орынды әрқашан анықтауға рұқсат беріңіз',
        'ky': 'Жайгашкан жерди ар дайым колдонууга уруксат бериңиз',
        'pl': 'Zezwól na lokalizację cały czas',
        'pt': 'Permitir localização o tempo todo',
        'ru': 'Разрешите геолокацию всегда',
        'tg': 'Ҷойгиршавиро ҳамеша иҷозат диҳед',
        'tk': 'Ýerleşişe hemişe rugsat beriň',
        'uz': 'Joylashuvga doim ruxsat bering',
      });

  String get allowLocationAllTheTimeDescription => _pick({
        'ar':
            'يسمح أندرويد حالياً بالموقع فقط أثناء فتح التطبيق. لتتبع الموقع في الخلفية، افتح إعدادات التطبيق واختر "السماح طوال الوقت".',
        'az':
            'Hazırda Android məkan girişinə yalnız tətbiq açıq olanda icazə verir. Fon izləməsi üçün tətbiq ayarlarını açın və "Həmişə icazə ver" seçin.',
        'de':
            'Android erlaubt den Standort derzeit nur, wenn die App geöffnet ist. Öffne für die Hintergrundortung die App-Einstellungen und wähle „Immer erlauben“.',
        'en':
            'Android currently allows location only while the app is open. For background tracking, open app settings and choose "Allow all the time".',
        'es':
            'Android actualmente permite la ubicación solo mientras la app está abierta. Para el rastreo en segundo plano, abre los ajustes de la app y elige "Permitir todo el tiempo".',
        'fr':
            "Android n'autorise actuellement la localisation que lorsque l'application est ouverte. Pour le suivi en arrière-plan, ouvrez les réglages de l'application et choisissez « Toujours autoriser ».",
        'hy':
            'Այս պահին Android-ը տեղադրությունը թույլ է տալիս միայն բացված հավելվածի ժամանակ։ Ֆոնային հետևման համար բացեք հավելվածի կարգավորումները և ընտրեք «Թույլատրել միշտ»։',
        'it':
            'Android al momento consente la posizione solo quando l’app è aperta. Per il tracciamento in background, apri le impostazioni dell’app e scegli "Consenti sempre".',
        'ka':
            'ამჟამად Android მდებარეობას მხოლოდ გახსნილი აპის დროს აძლევს. ფონური ტრეკინგისთვის გახსენით აპის პარამეტრები და აირჩიეთ "ყოველთვის დაშვება".',
        'kk':
            'Қазір Android орналасуды тек қолданба ашық кезде ғана рұқсат етеді. Фондық бақылау үшін қолданба баптауларын ашып, "Әрқашан рұқсат беру" таңдаңыз.',
        'ky':
            'Азыр Android жайгашкан жерге колдонмо ачык болгондо гана уруксат берет. Фондук көзөмөл үчүн колдонмонун жөндөөлөрүн ачып, "Ар дайым уруксат берүү" дегенди тандаңыз.',
        'pl':
            'Android obecnie zezwala na lokalizację tylko wtedy, gdy aplikacja jest otwarta. Aby włączyć śledzenie w tle, otwórz ustawienia aplikacji i wybierz „Zezwalaj cały czas”.',
        'pt':
            'No momento, o Android permite a localização apenas enquanto o app está aberto. Para rastreamento em segundo plano, abra as configurações do app e escolha "Permitir o tempo todo".',
        'ru':
            'Сейчас Android разрешил доступ к геолокации только при открытом приложении. Для фоновой передачи местоположения откройте настройки приложения и выберите «Разрешить всегда».',
        'tg':
            'Ҳоло Android ҷойгиршавиро танҳо ҳангоми кушода будани барнома иҷозат медиҳад. Барои пайгирии пасзамина, танзимоти барномаро кушоед ва "Ҳамеша иҷозат диҳед"-ро интихоб кунед.',
        'tk':
            'Android häzir ýerleşişe diňe programma açyk wagty rugsat berýär. Fon gözegçiligi üçin programmanyň sazlamalaryny açyp "Hemişe rugsat ber" saýlaň.',
        'uz':
            'Hozir Android joylashuvga faqat ilova ochiq paytda ruxsat beradi. Fon kuzatuvi uchun ilova sozlamalarini ochib "Doim ruxsat berish"ni tanlang.',
      });

  String get disableBatteryOptimization => _pick({
        'ar': 'عطّل تحسين البطارية',
        'az': 'Batareya optimallaşdırmasını söndürün',
        'de': 'Akku-Optimierung deaktivieren',
        'en': 'Disable battery optimization',
        'es': 'Desactivar optimización de batería',
        'fr': "Désactiver l'optimisation de la batterie",
        'hy': 'Անջատեք մարտկոցի օպտիմիզացիան',
        'it': 'Disattiva ottimizzazione batteria',
        'ka': 'გამორთეთ ბატარეის ოპტიმიზაცია',
        'kk': 'Батареяны оңтайландыруды өшіріңіз',
        'ky': 'Батареяны оптималдаштырууну өчүрүңүз',
        'pl': 'Wyłącz optymalizację baterii',
        'pt': 'Desativar otimização da bateria',
        'ru': 'Отключите оптимизацию батареи',
        'tg': 'Оптимизатсияи батареяро хомӯш кунед',
        'tk': 'Batareýa optimizasiýasyny öçüriň',
        'uz': 'Batareya optimallashtirishni o‘chiring',
      });

  String get batteryOptimizationDescription => _pick({
        'ar':
            'تقوم بعض أجهزة أندرويد بإيقاف الموقع في الخلفية والإشعارات والأوامر حتى مع منح الأذونات. اسمح للتطبيق بالعمل دون قيود البطارية.',
        'az':
            'Bəzi Android cihazları icazələr verilsə belə fon məkanını, bildirişləri və əmrləri dayandırır. Tətbiqin batareya məhdudiyyəti olmadan işləməsinə icazə verin.',
        'de':
            'Einige Android-Geräte stoppen Standort, Benachrichtigungen und Befehle im Hintergrund selbst bei erteilten Berechtigungen. Erlaube der App, ohne Akku-Beschränkungen zu laufen.',
        'en':
            'Some Android devices stop background location, notifications, and commands even when permissions are granted. Allow the app to run without battery restrictions.',
        'es':
            'Algunos dispositivos Android detienen la ubicación en segundo plano, las notificaciones y los comandos incluso con los permisos otorgados. Permite que la app funcione sin restricciones de batería.',
        'fr':
            'Certains appareils Android arrêtent la localisation en arrière-plan, les notifications et les commandes même lorsque les autorisations sont accordées. Autorisez l’application à fonctionner sans restriction de batterie.',
        'hy':
            'Որոշ Android սարքեր նույնիսկ թույլտվությունների առկայության դեպքում դադարեցնում են ֆոնային տեղորոշումը, ծանուցումները և հրամանները։ Թույլ տվեք հավելվածին աշխատել առանց մարտկոցի սահմանափակումների։',
        'it':
            'Alcuni dispositivi Android interrompono posizione in background, notifiche e comandi anche con i permessi concessi. Consenti all’app di funzionare senza restrizioni della batteria.',
        'ka':
            'ზოგი Android მოწყობილობა ნებართვების არსებობის შემთხვევაშიც აჩერებს ფონურ მდებარეობას, შეტყობინებებს და ბრძანებებს. მისცით აპს მუშაობის უფლება ბატარეის შეზღუდვების გარეშე.',
        'kk':
            'Кейбір Android құрылғылары рұқсаттар берілсе де фондық орналасуды, хабарландыруларды және командаларды тоқтатады. Қолданбаға батарея шектеулерінсіз жұмыс істеуге рұқсат беріңіз.',
        'ky':
            'Айрым Android түзмөктөрү уруксаттар берилсе да фондук жайгашкан жерди, эскертмелерди жана буйруктарды токтотуп коёт. Колдонмого батарея чектөөсүз иштөөгө уруксат бериңиз.',
        'pl':
            'Niektóre urządzenia z Androidem zatrzymują lokalizację w tle, powiadomienia i polecenia nawet po nadaniu uprawnień. Zezwól aplikacji działać bez ograniczeń baterii.',
        'pt':
            'Alguns dispositivos Android interrompem localização em segundo plano, notificações e comandos mesmo com as permissões concedidas. Permita que o app funcione sem restrições de bateria.',
        'ru':
            'Некоторые устройства Android останавливают фоновую геолокацию, уведомления и команды даже при выданных разрешениях. Разрешите приложению работать без ограничений батареи.',
        'tg':
            'Баъзе дастгоҳҳои Android ҳатто бо иҷозатҳои додашуда ҷойгиршавии пасзамина, огоҳиномаҳо ва фармонҳоро қатъ мекунанд. Ба барнома иҷозат диҳед бе маҳдудияти батарея кор кунад.',
        'tk':
            'Käbir Android enjamlary rugsatlar berlenem bolsa fon ýerleşişini, bildirişleri we buýruklary saklaýar. Programmanyň batareýa çäklendirmesiz işlemegine rugsat beriň.',
        'uz':
            'Ba’zi Android qurilmalari ruxsatlar berilgan bo‘lsa ham fon joylashuvi, bildirishnomalar va buyruqlarni to‘xtatadi. Ilovaga batareya cheklovlarisiz ishlashga ruxsat bering.',
      });

  String get allowUnrestricted => _pick({
        'ar': 'السماح دون قيود',
        'az': 'Məhdudiyyətsiz icazə ver',
        'de': 'Uneingeschränkt erlauben',
        'en': 'Allow unrestricted',
        'es': 'Permitir sin restricciones',
        'fr': 'Autoriser sans restriction',
        'hy': 'Թույլատրել առանց սահմանափակման',
        'it': 'Consenti senza restrizioni',
        'ka': 'შეზღუდვის გარეშე დაშვება',
        'kk': 'Шектеусіз рұқсат беру',
        'ky': 'Чектөөсүз уруксат берүү',
        'pl': 'Zezwól bez ograniczeń',
        'pt': 'Permitir sem restrições',
        'ru': 'Разрешить без ограничений',
        'tg': 'Бе маҳдудият иҷозат диҳед',
        'tk': 'Çäklendirmesiz rugsat ber',
        'uz': 'Cheklovsiz ruxsat berish',
      });

  String get createRewardFirst => _pick({
        'ar': 'أنشئ مكافأة أولاً',
        'az': 'Əvvəlcə mükafat yaradın',
        'de': 'Erstelle zuerst eine Belohnung',
        'en': 'Create a reward first',
        'es': 'Crea primero una recompensa',
        'fr': "Créez d'abord une récompense",
        'hy': 'Սկզբում ստեղծեք պարգև',
        'it': 'Crea prima una ricompensa',
        'ka': 'ჯერ ჯილდო შექმენით',
        'kk': 'Алдымен марапат жасаңыз',
        'ky': 'Адегенде сыйлык түзүңүз',
        'pl': 'Najpierw utwórz nagrodę',
        'pt': 'Crie uma recompensa primeiro',
        'ru': 'Сначала создайте награду',
        'tg': 'Аввал мукофот созед',
        'tk': 'Ilki baýrak dörediň',
        'uz': 'Avval mukofot yarating',
      });

  String get createRewardFirstMessage => _pick({
        'ar': 'قبل إنشاء مهمة، أضف مكافأة واحدة على الأقل لهذا الطفل.',
        'az':
            'Tapşırıq yaratmazdan əvvəl bu uşaq üçün ən azı bir mükafat əlavə edin.',
        'de':
            'Bevor du eine Aufgabe erstellst, füge mindestens eine Belohnung für dieses Kind hinzu.',
        'en': 'Before creating a task, add at least one reward for this child.',
        'es':
            'Antes de crear una tarea, agrega al menos una recompensa para este niño.',
        'fr':
            "Avant de créer une tâche, ajoutez au moins une récompense pour cet enfant.",
        'hy':
            'Առաջադրանք ստեղծելուց առաջ այս երեխայի համար ավելացրեք առնվազն մեկ պարգև։',
        'it':
            'Prima di creare un compito, aggiungi almeno una ricompensa per questo bambino.',
        'ka': 'დავალების შექმნამდე ამ ბავშვისთვის მინიმუმ ერთი ჯილდო დაამატეთ.',
        'kk':
            'Тапсырма жасамас бұрын осы бала үшін кемінде бір марапат қосыңыз.',
        'ky':
            'Тапшырма түзөрдөн мурда бул бала үчүн жок дегенде бир сыйлык кошуңуз.',
        'pl':
            'Zanim utworzysz zadanie, dodaj co najmniej jedną nagrodę dla tego dziecka.',
        'pt':
            'Antes de criar uma tarefa, adicione pelo menos uma recompensa para esta criança.',
        'ru':
            'Перед созданием задания нужно добавить хотя бы одну награду для ребёнка.',
        'tg':
            'Пеш аз сохтани супориш барои ин кӯдак ҳадди ақал як мукофот илова кунед.',
        'tk': 'Wezipe döretmezden öň bu çaga üçin azyndan bir baýrak goşuň.',
        'uz':
            'Vazifa yaratishdan oldin bu bola uchun kamida bitta mukofot qo‘shing.',
      });

  String get createReward => _pick({
        'ar': 'إنشاء مكافأة',
        'az': 'Mükafat yarat',
        'de': 'Belohnung erstellen',
        'en': 'Create reward',
        'es': 'Crear recompensa',
        'fr': 'Créer une récompense',
        'hy': 'Ստեղծել պարգև',
        'it': 'Crea ricompensa',
        'ka': 'ჯილდოს შექმნა',
        'kk': 'Марапат жасау',
        'ky': 'Сыйлык түзүү',
        'pl': 'Utwórz nagrodę',
        'pt': 'Criar recompensa',
        'ru': 'Создать награду',
        'tg': 'Эҷоди мукофот',
        'tk': 'Baýrak döret',
        'uz': 'Mukofot yaratish',
      });

  String get addNewTask => _pick({
        'ar': 'إضافة مهمة جديدة',
        'az': 'Yeni tapşırıq əlavə et',
        'de': 'Neue Aufgabe hinzufügen',
        'en': 'Add New Task',
        'es': 'Agregar nueva tarea',
        'fr': 'Ajouter une nouvelle tâche',
        'hy': 'Ավելացնել նոր առաջադրանք',
        'it': 'Aggiungi nuova attività',
        'ka': 'ახალი დავალების დამატება',
        'kk': 'Жаңа тапсырма қосу',
        'ky': 'Жаңы тапшырма кошуу',
        'pl': 'Dodaj nowe zadanie',
        'pt': 'Adicionar nova tarefa',
        'ru': 'Добавить новое задание',
        'tg': 'Илова кардани супориши нав',
        'tk': 'Täze wezipe goş',
        'uz': 'Yangi vazifa qo‘shish',
      });

  String get taskTitle => _pick({
        'ar': 'عنوان المهمة',
        'az': 'Tapşırıq adı',
        'de': 'Aufgabentitel',
        'en': 'Task Title',
        'es': 'Título de la tarea',
        'fr': 'Titre de la tâche',
        'hy': 'Առաջադրանքի վերնագիր',
        'it': 'Titolo attività',
        'ka': 'დავალების სათაური',
        'kk': 'Тапсырма атауы',
        'ky': 'Тапшырманын аталышы',
        'pl': 'Tytuł zadania',
        'pt': 'Título da tarefa',
        'ru': 'Название задания',
        'tg': 'Номи супориш',
        'tk': 'Wezipäniň ady',
        'uz': 'Vazifa sarlavhasi',
      });

  String get taskTitleHint => _pick({
        'ar': 'مثال: رتّب غرفتك',
        'az': 'məs. Otağını yığışdır',
        'de': 'z. B. Räume dein Zimmer auf',
        'en': 'e.g. Clean your room',
        'es': 'p. ej. Ordena tu habitación',
        'fr': 'ex. Range ta chambre',
        'hy': 'օր.՝ Մաքրիր սենյակդ',
        'it': 'es. Sistema la tua stanza',
        'ka': 'მაგ. დაალაგე ოთახი',
        'kk': 'мысалы, Бөлмеңді жина',
        'ky': 'мисалы, Бөлмөңдү жыйна',
        'pl': 'np. Posprzątaj swój pokój',
        'pt': 'ex.: Arrume seu quarto',
        'ru': 'например, Убери свою комнату',
        'tg': 'масалан, Хонаатро ҷамъ кун',
        'tk': 'meselem, Otagyňy tertiple',
        'uz': 'masalan, Xonangni yig‘ishtir',
      });

  String get descriptionLabel => _pick({
        'ar': 'الوصف',
        'az': 'Təsvir',
        'de': 'Beschreibung',
        'en': 'Description',
        'es': 'Descripción',
        'fr': 'Description',
        'hy': 'Նկարագրություն',
        'it': 'Descrizione',
        'ka': 'აღწერა',
        'kk': 'Сипаттама',
        'ky': 'Сүрөттөмө',
        'pl': 'Opis',
        'pt': 'Descrição',
        'ru': 'Описание',
        'tg': 'Тавсиф',
        'tk': 'Düşündiriş',
        'uz': 'Tavsif',
      });

  String get taskDescriptionHint => _pick({
        'ar': 'مثال: رتّب الألعاب، رتب السرير...',
        'az': 'məs. Oyuncaqları yığ, çarpayını düzəlt...',
        'de': 'z. B. Spielzeug wegräumen, Bett machen...',
        'en': 'e.g. Put away toys, make the bed...',
        'es': 'p. ej. Guarda los juguetes, haz la cama...',
        'fr': 'ex. Range les jouets, fais le lit...',
        'hy': 'օր.՝ հավաքիր խաղալիքները, հարդարիր անկողինը...',
        'it': 'es. Metti via i giocattoli, rifai il letto...',
        'ka': 'მაგ. აალაგე სათამაშოები, გაასწორე საწოლი...',
        'kk': 'мысалы, Ойыншықтарды жина, төсегіңді жина...',
        'ky': 'мисалы, Оюнчуктарды жыйна, төшөгүңдү жыйна...',
        'pl': 'np. Odłóż zabawki, pościel łóżko...',
        'pt': 'ex.: Guarde os brinquedos, arrume a cama...',
        'ru': 'например, Убери игрушки, заправь кровать...',
        'tg': 'масалан, Бозичаҳоро ҷамъ кун, катро рост кун...',
        'tk': 'meselem, Oýnawaçlary ýygnap goý, düşegi düzelt...',
        'uz':
            'masalan, O‘yinchoqlarni yig‘ishtir, karavotni tartibga keltir...',
      });

  String get rewardStars => _pick({
        'ar': 'نجوم المكافأة',
        'az': 'Mükafat ulduzları',
        'de': 'Belohnungssterne',
        'en': 'Reward Stars',
        'es': 'Estrellas de recompensa',
        'fr': 'Étoiles de récompense',
        'hy': 'Պարգևատրման աստղեր',
        'it': 'Stelle ricompensa',
        'ka': 'ჯილდოს ვარსკვლავები',
        'kk': 'Марапат жұлдыздары',
        'ky': 'Сыйлык жылдыздары',
        'pl': 'Gwiazdki nagrody',
        'pt': 'Estrelas de recompensa',
        'ru': 'Звёзды награды',
        'tg': 'Ситораҳои мукофот',
        'tk': 'Baýrak ýyldyzlary',
        'uz': 'Mukofot yulduzlari',
      });

  String get addTask => _pick({
        'ar': 'إضافة مهمة',
        'az': 'Tapşırıq əlavə et',
        'de': 'Aufgabe hinzufügen',
        'en': 'Add Task',
        'es': 'Agregar tarea',
        'fr': 'Ajouter une tâche',
        'hy': 'Ավելացնել առաջադրանք',
        'it': 'Aggiungi attività',
        'ka': 'დავალების დამატება',
        'kk': 'Тапсырма қосу',
        'ky': 'Тапшырма кошуу',
        'pl': 'Dodaj zadanie',
        'pt': 'Adicionar tarefa',
        'ru': 'Добавить задание',
        'tg': 'Илова кардани супориш',
        'tk': 'Wezipe goş',
        'uz': 'Vazifa qo‘shish',
      });

  String get addReward => _pick({
        'ar': 'إضافة مكافأة',
        'az': 'Mükafat əlavə et',
        'de': 'Belohnung hinzufügen',
        'en': 'Add Reward',
        'es': 'Agregar recompensa',
        'fr': 'Ajouter une récompense',
        'hy': 'Ավելացնել պարգև',
        'it': 'Aggiungi ricompensa',
        'ka': 'ჯილდოს დამატება',
        'kk': 'Марапат қосу',
        'ky': 'Сыйлык кошуу',
        'pl': 'Dodaj nagrodę',
        'pt': 'Adicionar recompensa',
        'ru': 'Добавить награду',
        'tg': 'Илова кардани мукофот',
        'tk': 'Baýrak goş',
        'uz': 'Mukofot qo‘shish',
      });

  String get rewardTitle => _pick({
        'ar': 'عنوان المكافأة',
        'az': 'Mükafat adı',
        'de': 'Belohnungstitel',
        'en': 'Reward Title',
        'es': 'Título de la recompensa',
        'fr': 'Titre de la récompense',
        'hy': 'Պարգևի վերնագիր',
        'it': 'Titolo ricompensa',
        'ka': 'ჯილდოს სათაური',
        'kk': 'Марапат атауы',
        'ky': 'Сыйлыктын аталышы',
        'pl': 'Tytuł nagrody',
        'pt': 'Título da recompensa',
        'ru': 'Название награды',
        'tg': 'Номи мукофот',
        'tk': 'Baýragyň ady',
        'uz': 'Mukofot sarlavhasi',
      });

  String get rewardTitleHint => _pick({
        'ar': 'مثال: ليلة سينما',
        'az': 'məs. Kino axşamı',
        'de': 'z. B. Kinoabend',
        'en': 'e.g. Cinema Night',
        'es': 'p. ej. Noche de cine',
        'fr': 'ex. Soirée cinéma',
        'hy': 'օր.՝ Կինոյի երեկո',
        'it': 'es. Serata cinema',
        'ka': 'მაგ. კინოს საღამო',
        'kk': 'мысалы, Кино кеші',
        'ky': 'мисалы, Кино кечеси',
        'pl': 'np. Wieczór filmowy',
        'pt': 'ex.: Noite de cinema',
        'ru': 'например, Поход в кино',
        'tg': 'масалан, Шаби кино',
        'tk': 'meselem, Kino gijesi',
        'uz': 'masalan, Kino kechasi',
      });

  String get requiredStars => _pick({
        'ar': 'النجوم المطلوبة',
        'az': 'Tələb olunan ulduzlar',
        'de': 'Benötigte Sterne',
        'en': 'Required Stars',
        'es': 'Estrellas requeridas',
        'fr': 'Étoiles requises',
        'hy': 'Պահանջվող աստղեր',
        'it': 'Stelle richieste',
        'ka': 'საჭირო ვარსკვლავები',
        'kk': 'Қажетті жұлдыздар',
        'ky': 'Керектүү жылдыздар',
        'pl': 'Wymagane gwiazdki',
        'pt': 'Estrelas necessárias',
        'ru': 'Нужно звёзд',
        'tg': 'Ситораҳои зарурӣ',
        'tk': 'Gerek ýyldyzlar',
        'uz': 'Kerakli yulduzlar',
      });

  String get photoFromGallery => _pick({
        'ar': 'صورة من المعرض',
        'az': 'Qalereyadan şəkil',
        'de': 'Foto aus der Galerie',
        'en': 'Photo from gallery',
        'es': 'Foto de la galería',
        'fr': 'Photo depuis la galerie',
        'hy': 'Լուսանկար պատկերասրահից',
        'it': 'Foto dalla galleria',
        'ka': 'ფოტო გალერეიდან',
        'kk': 'Галереядан фото',
        'ky': 'Галереядан сүрөт',
        'pl': 'Zdjęcie z galerii',
        'pt': 'Foto da galeria',
        'ru': 'Фото из галереи',
        'tg': 'Сурат аз галерея',
        'tk': 'Galereýadan surat',
        'uz': 'Galereyadan foto',
      });

  String get photoFromCamera => _pick({
        'ar': 'صورة من الكاميرا',
        'az': 'Kameradan şəkil',
        'de': 'Foto mit der Kamera',
        'en': 'Photo from camera',
        'es': 'Foto de la cámara',
        'fr': 'Photo depuis la caméra',
        'hy': 'Լուսանկար տեսախցիկից',
        'it': 'Foto dalla fotocamera',
        'ka': 'ფოტო კამერიდან',
        'kk': 'Камерадан фото',
        'ky': 'Камерадан сүрөт',
        'pl': 'Zdjęcie z aparatu',
        'pt': 'Foto da câmera',
        'ru': 'Фото с камеры',
        'tg': 'Сурат аз камера',
        'tk': 'Kameradan surat',
        'uz': 'Kameradan foto',
      });

  String get videoFromGallery => _pick({
        'ar': 'فيديو من المعرض',
        'az': 'Qalereyadan video',
        'de': 'Video aus der Galerie',
        'en': 'Video from gallery',
        'es': 'Video de la galería',
        'fr': 'Vidéo depuis la galerie',
        'hy': 'Տեսանյութ պատկերասրահից',
        'it': 'Video dalla galleria',
        'ka': 'ვიდეო გალერეიდან',
        'kk': 'Галереядан видео',
        'ky': 'Галереядан видео',
        'pl': 'Film z galerii',
        'pt': 'Vídeo da galeria',
        'ru': 'Видео из галереи',
        'tg': 'Видео аз галерея',
        'tk': 'Galereýadan wideo',
        'uz': 'Galereyadan video',
      });

  String get videoFromCamera => _pick({
        'ar': 'فيديو من الكاميرا',
        'az': 'Kameradan video',
        'de': 'Video mit der Kamera',
        'en': 'Video from camera',
        'es': 'Video de la cámara',
        'fr': 'Vidéo depuis la caméra',
        'hy': 'Տեսանյութ տեսախցիկից',
        'it': 'Video dalla fotocamera',
        'ka': 'ვიდეო კამერიდან',
        'kk': 'Камерадан видео',
        'ky': 'Камерадан видео',
        'pl': 'Film z kamery',
        'pt': 'Vídeo da câmera',
        'ru': 'Видео с камеры',
        'tg': 'Видео аз камера',
        'tk': 'Kameradan wideo',
        'uz': 'Kameradan video',
      });

  String get sendingItem => _pick({
        'ar': 'جاري الإرسال...',
        'az': 'Element göndərilir...',
        'de': 'Element wird gesendet...',
        'en': 'Sending item...',
        'es': 'Enviando elemento...',
        'fr': "Envoi de l'élément...",
        'hy': 'Ուղարկվում է...',
        'it': 'Invio elemento...',
        'ka': 'ელემენტი იგზავნება...',
        'kk': 'Элемент жіберілуде...',
        'ky': 'Элемент жөнөтүлүүдө...',
        'pl': 'Wysyłanie elementu...',
        'pt': 'Enviando item...',
        'ru': 'Отправляется элемент...',
        'tg': 'Элемент фиристода мешавад...',
        'tk': 'Element iberilýär...',
        'uz': 'Element yuborilmoqda...',
      });

  String sendingItems(int count) => _fill(
        _pick({
          'ar': 'جاري إرسال {count} عناصر...',
          'az': '{count} element göndərilir...',
          'de': '{count} Elemente werden gesendet...',
          'en': 'Sending {count} items...',
          'es': 'Enviando {count} elementos...',
          'fr': 'Envoi de {count} éléments...',
          'hy': 'Ուղարկվում է {count} տարր...',
          'it': 'Invio di {count} elementi...',
          'ka': 'იგზავნება {count} ელემენტი...',
          'kk': '{count} элемент жіберілуде...',
          'ky': '{count} элемент жөнөтүлүүдө...',
          'pl': 'Wysyłanie {count} elementów...',
          'pt': 'Enviando {count} itens...',
          'ru': 'Отправляется {count} элементов...',
          'tg': '{count} элемент фиристода мешавад...',
          'tk': '{count} element iberilýär...',
          'uz': '{count} ta element yuborilmoqda...',
        }),
        {'count': count},
      );

  String get sendMessagePhotoVideo => _pick({
        'ar': 'أرسل رسالة أو صورة أو فيديو...',
        'az': 'Mesaj, şəkil və ya video göndərin...',
        'de': 'Nachricht, Foto oder Video senden...',
        'en': 'Send a message, photo or video...',
        'es': 'Envía un mensaje, foto o video...',
        'fr': 'Envoyer un message, une photo ou une vidéo...',
        'hy': 'Ուղարկեք հաղորդագրություն, լուսանկար կամ տեսանյութ...',
        'it': 'Invia un messaggio, una foto o un video...',
        'ka': 'გააგზავნე შეტყობინება, ფოტო ან ვიდეო...',
        'kk': 'Хабарлама, фото немесе видео жіберіңіз...',
        'ky': 'Билдирүү, сүрөт же видео жөнөтүңүз...',
        'pl': 'Wyślij wiadomość, zdjęcie lub wideo...',
        'pt': 'Envie uma mensagem, foto ou vídeo...',
        'ru': 'Отправьте сообщение, фото или видео...',
        'tg': 'Паём, сурат ё видео фиристед...',
        'tk': 'Habar, surat ýa wideo iberiň...',
        'uz': 'Xabar, foto yoki video yuboring...',
      });

  String get weeklyRewards => _pick({
        'ar': 'المكافآت الأسبوعية',
        'az': 'Həftəlik mükafatlar',
        'de': 'Wöchentliche Belohnungen',
        'en': 'Weekly Rewards',
        'es': 'Recompensas semanales',
        'fr': 'Récompenses hebdomadaires',
        'hy': 'Շաբաթական պարգևներ',
        'it': 'Ricompense settimanali',
        'ka': 'კვირის ჯილდოები',
        'kk': 'Апталық марапаттар',
        'ky': 'Апталык сыйлыктар',
        'pl': 'Nagrody tygodniowe',
        'pt': 'Recompensas semanais',
        'ru': 'Недельные награды',
        'tg': 'Мукофотҳои ҳафтаина',
        'tk': 'Hepdelik baýraklar',
        'uz': 'Haftalik mukofotlar',
      });

  String get starsEarned => _pick({
        'ar': 'نجوم مكتسبة',
        'az': 'Qazanılmış ulduzlar',
        'de': 'Verdiente Sterne',
        'en': 'Stars earned',
        'es': 'Estrellas ganadas',
        'fr': 'Étoiles gagnées',
        'hy': 'Վաստակած աստղեր',
        'it': 'Stelle guadagnate',
        'ka': 'მიღებული ვარსკვლავები',
        'kk': 'Жиналған жұлдыздар',
        'ky': 'Топтолгон жылдыздар',
        'pl': 'Zdobyte gwiazdki',
        'pt': 'Estrelas conquistadas',
        'ru': 'Заработано звёзд',
        'tg': 'Ситораҳои гирифташуда',
        'tk': 'Gazanylan ýyldyzlar',
        'uz': 'Topilgan yulduzlar',
      });

  String get setReward => _pick({
        'ar': 'حدّد مكافأة',
        'az': 'Mükafat təyin et',
        'de': 'Belohnung festlegen',
        'en': 'Set a reward',
        'es': 'Define una recompensa',
        'fr': 'Définir une récompense',
        'hy': 'Սահմանեք պարգև',
        'it': 'Imposta una ricompensa',
        'ka': 'დააყენე ჯილდო',
        'kk': 'Марапат орнатыңыз',
        'ky': 'Сыйлык коюңуз',
        'pl': 'Ustaw nagrodę',
        'pt': 'Defina uma recompensa',
        'ru': 'Установите награду',
        'tg': 'Мукофотро таъин кунед',
        'tk': 'Baýrak belläň',
        'uz': 'Mukofot belgilang',
      });

  String starsUntilReward(int count, String rewardTitle) => _fill(
        _pick({
          'ar': 'تبقى {count} نجمة حتى مكافأة {rewardTitle}!',
          'az': '{rewardTitle} mükafatına qədər {count} ulduz qaldı!',
          'de': 'Noch {count} Sterne bis zur Belohnung {rewardTitle}!',
          'en': '{count} more stars until {rewardTitle} reward!',
          'es': '¡{count} estrellas más para la recompensa {rewardTitle}!',
          'fr': 'Encore {count} étoiles avant la récompense {rewardTitle} !',
          'hy': '{rewardTitle} պարգևին մնացել է ևս {count} աստղ։',
          'it':
              'Ancora {count} stelle per ottenere la ricompensa {rewardTitle}!',
          'ka': 'კიდევ {count} ვარსკვლავი ჯილდომდე: {rewardTitle}!',
          'kk': '{rewardTitle} марапатына дейін тағы {count} жұлдыз қалды!',
          'ky': '{rewardTitle} сыйлыгына чейин дагы {count} жылдыз калды!',
          'pl': 'Jeszcze {count} gwiazdek do nagrody {rewardTitle}!',
          'pt': 'Faltam {count} estrelas para a recompensa {rewardTitle}!',
          'ru': 'Ещё {count} звёзд до награды {rewardTitle}!',
          'tg': 'То мукофоти {rewardTitle} боз {count} ситора мондааст!',
          'tk': '{rewardTitle} baýragyna çenli ýene {count} ýyldyz gerek!',
          'uz': '{rewardTitle} mukofotigacha yana {count} yulduz kerak!',
        }),
        {
          'count': count,
          'rewardTitle': rewardTitle,
        },
      );

  String uploadingPercent(int percent) => _fill(
        _pick({
          'ar': 'جارٍ الرفع {percent}%',
          'az': 'Yüklənir {percent}%',
          'de': 'Wird hochgeladen {percent}%',
          'en': 'Uploading {percent}%',
          'es': 'Subiendo {percent}%',
          'fr': 'Téléversement {percent}%',
          'hy': 'Վերբեռնում {percent}%',
          'it': 'Caricamento {percent}%',
          'ka': 'იტვირთება {percent}%',
          'kk': 'Жүктелуде {percent}%',
          'ky': 'Жүктөлүүдө {percent}%',
          'pl': 'Przesyłanie {percent}%',
          'pt': 'Enviando {percent}%',
          'ru': 'Загрузка {percent}%',
          'tg': 'Боркунӣ {percent}%',
          'tk': 'Ýüklenýär {percent}%',
          'uz': 'Yuklanmoqda {percent}%',
        }),
        {'percent': percent},
      );

  String get sending => _pick({
        'ar': 'جاري الإرسال...',
        'az': 'Göndərilir...',
        'de': 'Wird gesendet...',
        'en': 'Sending...',
        'es': 'Enviando...',
        'fr': 'Envoi...',
        'hy': 'Ուղարկվում է...',
        'it': 'Invio...',
        'ka': 'იგზავნება...',
        'kk': 'Жіберілуде...',
        'ky': 'Жөнөтүлүүдө...',
        'pl': 'Wysyłanie...',
        'pt': 'Enviando...',
        'ru': 'Отправка...',
        'tg': 'Фиристода мешавад...',
        'tk': 'Iberilýär...',
        'uz': 'Yuborilmoqda...',
      });

  String get videoIsUploading => _pick({
        'ar': 'يتم رفع الفيديو',
        'az': 'Video yüklənir',
        'de': 'Video wird hochgeladen',
        'en': 'Video is uploading',
        'es': 'El video se está subiendo',
        'fr': 'La vidéo est en cours de téléversement',
        'hy': 'Տեսանյութը վերբեռնվում է',
        'it': 'Il video è in caricamento',
        'ka': 'ვიდეო იტვირთება',
        'kk': 'Видео жүктелуде',
        'ky': 'Видео жүктөлүүдө',
        'pl': 'Film jest przesyłany',
        'pt': 'O vídeo está sendo enviado',
        'ru': 'Видео загружается',
        'tg': 'Видео бор мешавад',
        'tk': 'Wideo ýüklenýär',
        'uz': 'Video yuklanmoqda',
      });

  String get videoAttached => _pick({
        'ar': 'تم إرفاق الفيديو',
        'az': 'Video əlavə olundu',
        'de': 'Video angehängt',
        'en': 'Video attached',
        'es': 'Video adjunto',
        'fr': 'Vidéo jointe',
        'hy': 'Տեսանյութը կցված է',
        'it': 'Video allegato',
        'ka': 'ვიდეო მიმაგრებულია',
        'kk': 'Видео тіркелді',
        'ky': 'Видео тиркелди',
        'pl': 'Dołączono film',
        'pt': 'Vídeo anexado',
        'ru': 'Видео прикреплено',
        'tg': 'Видео замима шуд',
        'tk': 'Wideo goşuldy',
        'uz': 'Video biriktirildi',
      });

  String get fileIsUploading => _pick({
        'ar': 'يتم رفع الملف',
        'az': 'Fayl yüklənir',
        'de': 'Datei wird hochgeladen',
        'en': 'File is uploading',
        'es': 'El archivo se está subiendo',
        'fr': 'Le fichier est en cours de téléversement',
        'hy': 'Ֆայլը վերբեռնվում է',
        'it': 'Il file è in caricamento',
        'ka': 'ფაილი იტვირთება',
        'kk': 'Файл жүктелуде',
        'ky': 'Файл жүктөлүүдө',
        'pl': 'Plik jest przesyłany',
        'pt': 'O arquivo está sendo enviado',
        'ru': 'Файл загружается',
        'tg': 'Файл бор мешавад',
        'tk': 'Faýl ýüklenýär',
        'uz': 'Fayl yuklanmoqda',
      });

  String get fileAttached => _pick({
        'ar': 'تم إرفاق الملف',
        'az': 'Fayl əlavə olundu',
        'de': 'Datei angehängt',
        'en': 'File attached',
        'es': 'Archivo adjunto',
        'fr': 'Fichier joint',
        'hy': 'Ֆայլը կցված է',
        'it': 'File allegato',
        'ka': 'ფაილი მიმაგრებულია',
        'kk': 'Файл тіркелді',
        'ky': 'Файл тиркелди',
        'pl': 'Załączono plik',
        'pt': 'Arquivo anexado',
        'ru': 'Файл прикреплён',
        'tg': 'Файл замима шуд',
        'tk': 'Faýl goşuldy',
        'uz': 'Fayl biriktirildi',
      });

  String get taskCompletedStatus => _pick({
        'ar': 'مكتملة',
        'az': 'Tamamlandı',
        'de': 'ERLEDIGT',
        'en': 'COMPLETED',
        'es': 'COMPLETADA',
        'fr': 'TERMINÉE',
        'hy': 'ԱՎԱՐՏՎԱԾ',
        'it': 'COMPLETATA',
        'ka': 'დასრულდა',
        'kk': 'ОРЫНДАЛДЫ',
        'ky': 'АТКАРЫЛДЫ',
        'pl': 'UKOŃCZONE',
        'pt': 'CONCLUÍDA',
        'ru': 'ВЫПОЛНЕНО',
        'tg': 'ИҶРО ШУД',
        'tk': 'TAMAMLANDY',
        'uz': 'BAJARILDI',
      });

  String get taskApprovedStatus => _pick({
        'ar': 'موافق عليها',
        'az': 'Təsdiqləndi',
        'de': 'GENEHMIGT',
        'en': 'APPROVED',
        'es': 'APROBADA',
        'fr': 'APPROUVÉE',
        'hy': 'ՀԱՍՏԱՏՎԱԾ',
        'it': 'APPROVATA',
        'ka': 'დამტკიცდა',
        'kk': 'МАҚҰЛДАНДЫ',
        'ky': 'БЕКИТИЛДИ',
        'pl': 'ZATWIERDZONE',
        'pt': 'APROVADA',
        'ru': 'ОДОБРЕНО',
        'tg': 'ТАСДИҚ ШУД',
        'tk': 'MAKULLANDY',
        'uz': 'TASDIQLANDI',
      });

  String get taskPendingStatus => _pick({
        'ar': 'قيد الانتظار',
        'az': 'Gözləmədə',
        'de': 'AUSSTEHEND',
        'en': 'PENDING',
        'es': 'PENDIENTE',
        'fr': 'EN ATTENTE',
        'hy': 'ՍՊԱՍՄԱՆ ՄԵՋ',
        'it': 'IN ATTESA',
        'ka': 'მოლოდინში',
        'kk': 'КҮТУДЕ',
        'ky': 'КҮТҮҮДӨ',
        'pl': 'OCZEKUJE',
        'pt': 'PENDENTE',
        'ru': 'ОЖИДАЕТСЯ',
        'tg': 'ДАР ИНТИЗОР',
        'tk': 'GARAŞYLÝAR',
        'uz': 'KUTILMOQDA',
      });

  String get rewardLabel => _pick({
        'ar': 'المكافأة:',
        'az': 'Mükafat:',
        'de': 'Belohnung:',
        'en': 'Reward:',
        'es': 'Recompensa:',
        'fr': 'Récompense :',
        'hy': 'Պարգև՝',
        'it': 'Ricompensa:',
        'ka': 'ჯილდო:',
        'kk': 'Марапат:',
        'ky': 'Сыйлык:',
        'pl': 'Nagroda:',
        'pt': 'Recompensa:',
        'ru': 'Награда:',
        'tg': 'Мукофот:',
        'tk': 'Baýrak:',
        'uz': 'Mukofot:',
      });

  String get starsWord => _pick({
        'ar': 'نجوم',
        'az': 'ulduz',
        'de': 'Sterne',
        'en': 'Stars',
        'es': 'estrellas',
        'fr': 'étoiles',
        'hy': 'աստղ',
        'it': 'stelle',
        'ka': 'ვარსკვლავი',
        'kk': 'жұлдыз',
        'ky': 'жылдыз',
        'pl': 'gwiazdek',
        'pt': 'estrelas',
        'ru': 'звёзд',
        'tg': 'ситора',
        'tk': 'ýyldyz',
        'uz': 'yulduz',
      });

  String get markAsComplete => _pick({
        'ar': 'وضع علامة كمكتملة',
        'az': 'Tamamlandı kimi qeyd et',
        'de': 'Als erledigt markieren',
        'en': 'Mark as Complete',
        'es': 'Marcar como completada',
        'fr': 'Marquer comme terminée',
        'hy': 'Նշել որպես ավարտված',
        'it': 'Segna come completata',
        'ka': 'მონიშნე დასრულებულად',
        'kk': 'Орындалды деп белгілеу',
        'ky': 'Аткарылды деп белгилөө',
        'pl': 'Oznacz jako ukończone',
        'pt': 'Marcar como concluída',
        'ru': 'Отметить как выполненное',
        'tg': 'Ҳамчун иҷрошуда қайд кардан',
        'tk': 'Tamamlandy diýip belle',
        'uz': 'Bajarildi deb belgilash',
      });

  String get approveAndAwardStars => _pick({
        'ar': 'اعتماد ومنح النجوم',
        'az': 'Təsdiqlə və ulduz ver',
        'de': 'Bestätigen und Sterne vergeben',
        'en': 'Approve & Award Stars',
        'es': 'Aprobar y otorgar estrellas',
        'fr': 'Approuver et attribuer des étoiles',
        'hy': 'Հաստատել և տալ աստղեր',
        'it': 'Approva e assegna stelle',
        'ka': 'დაამტკიცე და მიანიჭე ვარსკვლავები',
        'kk': 'Мақұлдап, жұлдыз беру',
        'ky': 'Бекитип, жылдыз берүү',
        'pl': 'Zatwierdź i przyznaj gwiazdki',
        'pt': 'Aprovar e dar estrelas',
        'ru': 'Одобрить и начислить звёзды',
        'tg': 'Тасдиқ ва додани ситораҳо',
        'tk': 'Makulla we ýyldyz ber',
        'uz': 'Tasdiqlash va yulduz berish',
      });

  String completedStarsEarned(int stars) => _fill(
        _pick({
          'ar': 'اكتملت! تم كسب {stars} نجوم',
          'az': 'Tamamlandı! +{stars} ulduz qazanıldı',
          'de': 'Erledigt! +{stars} Sterne verdient',
          'en': 'Completed! +{stars} stars earned',
          'es': '¡Completada! +{stars} estrellas ganadas',
          'fr': 'Terminée ! +{stars} étoiles gagnées',
          'hy': 'Ավարտված է։ +{stars} աստղ ստացվեց',
          'it': 'Completata! +{stars} stelle guadagnate',
          'ka': 'დასრულდა! +{stars} ვარსკვლავი მიღებულია',
          'kk': 'Орындалды! +{stars} жұлдыз алынды',
          'ky': 'Аткарылды! +{stars} жылдыз алынды',
          'pl': 'Ukończono! +{stars} gwiazdek zdobyto',
          'pt': 'Concluída! +{stars} estrelas ganhas',
          'ru': 'Выполнено! +{stars} звёзд заработано',
          'tg': 'Иҷро шуд! +{stars} ситора гирифта шуд',
          'tk': 'Tamamlandy! +{stars} ýyldyz gazanyldy',
          'uz': 'Bajarildi! +{stars} yulduz olindi',
        }),
        {'stars': stars},
      );

  String get waitingForChildToComplete => _pick({
        'ar': 'ننتظر أن يكمل الطفل...',
        'az': 'Uşağın tamamlaması gözlənilir...',
        'de': 'Warte darauf, dass das Kind abschließt...',
        'en': 'Waiting for child to complete...',
        'es': 'Esperando a que el niño complete...',
        'fr': "En attente que l'enfant termine...",
        'hy': 'Սպասում ենք, որ երեխան ավարտի...',
        'it': 'In attesa che il bambino completi...',
        'ka': 'ველოდებით, რომ ბავშვმა დაასრულოს...',
        'kk': 'Баланың аяқтауын күту...',
        'ky': 'Баланын бүтүрүшүн күтүп жатабыз...',
        'pl': 'Oczekiwanie na ukończenie przez dziecko...',
        'pt': 'Aguardando a criança concluir...',
        'ru': 'Ждём, когда ребёнок выполнит...',
        'tg': 'Интизори анҷом додани кӯдак...',
        'tk': 'Çaganyň tamamlamagyna garaşylýar...',
        'uz': 'Bolaning bajarishini kutmoqda...',
      });

  String get more => _pick({
        'ar': 'المزيد',
        'az': 'Daha çox',
        'de': 'Mehr',
        'en': 'More',
        'es': 'Más',
        'fr': 'Plus',
        'hy': 'Ավելին',
        'it': 'Altro',
        'ka': 'მეტი',
        'kk': 'Тағы',
        'ky': 'Дагы',
        'pl': 'Więcej',
        'pt': 'Mais',
        'ru': 'Ещё',
        'tg': 'Бештар',
        'tk': 'Köpräk',
        'uz': 'Ko‘proq',
      });
}

class ExtraTranslations {
  const ExtraTranslations(this.localeName);

  final String localeName;

  String _pick(Map<String, String> values) =>
      pickLocalizedExtra(localeName, values);

  String _fill(String template, Map<String, Object> values) =>
      fillLocalizedExtra(template, values);

  String get trackingNotification => _pick({
        'ar': 'تتم مشاركة موقع الطفل والبطارية',
        'az': 'Uşağın məkanı və batareyası paylaşılır',
        'de': 'Standort und Akku des Kindes werden geteilt',
        'en': 'Child location and battery are being shared',
        'es': 'La ubicación y la batería del niño se están compartiendo',
        'fr': "La position et la batterie de l'enfant sont partagées",
        'hy': 'Երեխայի տեղադրությունն ու մարտկոցը փոխանցվում են',
        'it': 'La posizione e la batteria del bambino vengono condivise',
        'ka': 'ბავშვის მდებარეობა და ბატარეა იგზავნება',
        'kk': 'Баланың орналасуы мен батареясы жіберіліп жатыр',
        'ky': 'Баланын жайгашкан жери жана батареясы жөнөтүлүүдө',
        'pl': 'Lokalizacja i bateria dziecka są udostępniane',
        'pt': 'A localização e a bateria da criança estão sendo compartilhadas',
        'ru': 'Геолокация и батарея ребёнка передаются',
        'tg': 'Ҷойгиршавӣ ва батареяи кӯдак фиристода мешаванд',
        'tk': 'Çaganyň ýerleşişi we batareýasy paýlaşylýar',
        'uz': 'Bolaning joylashuvi va batareyasi ulashilmoqda',
      });

  String get locationUnavailableCheckGps => _pick({
        'ar': 'الموقع غير متاح: تحقق من الإذن وGPS',
        'az': 'Məkan əlçatmazdır: icazəni və GPS-i yoxlayın',
        'de': 'Standort nicht verfügbar: Berechtigung und GPS prüfen',
        'en': 'Location unavailable: check permission and GPS',
        'es': 'Ubicación no disponible: revisa el permiso y el GPS',
        'fr': "Localisation indisponible : vérifiez l'autorisation et le GPS",
        'hy': 'Տեղադրությունը հասանելի չէ. ստուգեք թույլտվությունն ու GPS-ը',
        'it': 'Posizione non disponibile: controlla permesso e GPS',
        'ka': 'მდებარეობა მიუწვდომელია: შეამოწმეთ ნებართვა და GPS',
        'kk': 'Орналасу қолжетімсіз: рұқсат пен GPS-ті тексеріңіз',
        'ky': 'Жайгашкан жер жеткиликсиз: уруксатты жана GPSти текшериңиз',
        'pl': 'Lokalizacja niedostępna: sprawdź uprawnienia i GPS',
        'pt': 'Localização indisponível: verifique a permissão e o GPS',
        'ru': 'Геолокация недоступна: проверьте разрешение и GPS',
        'tg': 'Ҷойгиршавӣ дастнорас аст: иҷозат ва GPS-ро санҷед',
        'tk': 'Ýerleşiş elýeterli däl: rugsady we GPS-i barlaň',
        'uz': 'Joylashuv mavjud emas: ruxsat va GPSni tekshiring',
      });

  String get childLocationSharedToParent => _pick({
        'ar': 'يتم إرسال موقع الطفل إلى الوالد',
        'az': 'Uşağın məkanı valideynə ötürülür',
        'de': 'Standort des Kindes wird an die Eltern übertragen',
        'en': 'Child location is being shared with parent',
        'es': 'La ubicación del niño se está compartiendo con el padre',
        'fr': "La position de l'enfant est partagée avec le parent",
        'hy': 'Երեխայի տեղադրությունը փոխանցվում է ծնողին',
        'it': 'La posizione del bambino viene condivisa con il genitore',
        'ka': 'ბავშვის მდებარეობა ეგზავნება მშობელს',
        'kk': 'Баланың орналасуы ата-анаға жіберілуде',
        'ky': 'Баланын жайгашкан жери ата-энеге жөнөтүлүүдө',
        'pl': 'Lokalizacja dziecka jest udostępniana rodzicowi',
        'pt':
            'A localização da criança está sendo compartilhada com o responsável',
        'ru': 'Геолокация ребёнка передаётся родителю',
        'tg': 'Ҷойгиршавии кӯдак ба волидайн фиристода мешавад',
        'tk': 'Çaganyň ýerleşişi ene-ata iberilýär',
        'uz': 'Bolaning joylashuvi ota-onaga yuborilmoqda',
      });

  String locationActive(String batteryText) => _fill(
        _pick({
          'ar': 'الموقع نشط{batteryText}',
          'az': 'Məkan aktivdir{batteryText}',
          'de': 'Standort aktiv{batteryText}',
          'en': 'Location active{batteryText}',
          'es': 'Ubicación activa{batteryText}',
          'fr': 'Localisation active{batteryText}',
          'hy': 'Տեղադրությունը ակտիվ է{batteryText}',
          'it': 'Posizione attiva{batteryText}',
          'ka': 'მდებარეობა აქტიურია{batteryText}',
          'kk': 'Орналасу белсенді{batteryText}',
          'ky': 'Жайгашкан жер активдүү{batteryText}',
          'pl': 'Lokalizacja aktywna{batteryText}',
          'pt': 'Localização ativa{batteryText}',
          'ru': 'Геолокация активна{batteryText}',
          'tg': 'Ҷойгиршавӣ фаъол аст{batteryText}',
          'tk': 'Ýerleşiş işjeň{batteryText}',
          'uz': 'Joylashuv faol{batteryText}',
        }),
        {'batteryText': batteryText},
      );

  String get noNetworkWillRetry => _pick({
        'ar': 'لا توجد شبكة، سنعيد المحاولة تلقائياً',
        'az': 'Şəbəkə yoxdur, avtomatik yenidən cəhd edəcəyik',
        'de': 'Kein Netz, wir versuchen es automatisch erneut',
        'en': 'No network, will retry automatically',
        'es': 'Sin red, se reintentará automáticamente',
        'fr': 'Pas de réseau, nouvelle tentative automatique',
        'hy': 'Ցանց չկա, կրկին կփորձենք ավտոմատ',
        'it': 'Nessuna rete, nuovo tentativo automatico',
        'ka': 'ქსელი არ არის, ხელახლა ავტომატურად ვცდით',
        'kk': 'Желі жоқ, автоматты түрде қайта көреміз',
        'ky': 'Тармак жок, автоматтык түрдө кайра аракет кылабыз',
        'pl': 'Brak sieci, ponowimy automatycznie',
        'pt': 'Sem rede, tentaremos novamente automaticamente',
        'ru': 'Нет сети, повторим отправку автоматически',
        'tg': 'Шабака нест, худкор дубора кӯшиш мекунем',
        'tk': 'Tor ýok, awtomatiki täzeden synanyşarys',
        'uz': 'Tarmoq yo‘q, avtomatik qayta urinib ko‘riladi',
      });

  String get playingLoudSignal => _pick({
        'ar': 'تشغيل الإشارة العالية...',
        'az': 'Yüksək siqnal səsləndirilir...',
        'de': 'Lautes Signal wird abgespielt...',
        'en': 'Playing loud signal...',
        'es': 'Reproduciendo señal sonora...',
        'fr': 'Lecture du signal sonore...',
        'hy': 'Բարձր ազդանշանը միացված է...',
        'it': 'Riproduzione del segnale forte...',
        'ka': 'ხმამაღალი სიგნალი ირთვება...',
        'kk': 'Қатты дыбыс қосылып жатыр...',
        'ky': 'Катуу сигнал ойнотулууда...',
        'pl': 'Odtwarzanie głośnego sygnału...',
        'pt': 'Reproduzindo sinal sonoro...',
        'ru': 'Воспроизведение сигнала...',
        'tg': 'Сигнали баланд пахш мешавад...',
        'tk': 'Gaty sesli signal çalynýar...',
        'uz': 'Baland signal ijro etilmoqda...',
      });

  String get okAction => _pick({
        'ar': 'حسناً',
        'az': 'Oldu',
        'de': 'OK',
        'en': 'OK',
        'es': 'OK',
        'fr': 'OK',
        'hy': 'Լավ',
        'it': 'OK',
        'ka': 'კარგი',
        'kk': 'OK',
        'ky': 'Макул',
        'pl': 'OK',
        'pt': 'OK',
        'ru': 'ОК',
        'tg': 'Хуб',
        'tk': 'Bolýar',
        'uz': 'OK',
      });

  String get signInAsParent => _pick({
        'ar': 'تسجيل الدخول كوالد',
        'az': 'Valideyn kimi daxil ol',
        'de': 'Als Elternteil anmelden',
        'en': 'Sign in as parent',
        'es': 'Iniciar sesión como padre',
        'fr': 'Se connecter en tant que parent',
        'hy': 'Մուտք գործել որպես ծնող',
        'it': 'Accedi come genitore',
        'ka': 'შესვლა როგორც მშობელი',
        'kk': 'Ата-ана ретінде кіру',
        'ky': 'Ата-эне катары кирүү',
        'pl': 'Zaloguj się jako rodzic',
        'pt': 'Entrar como responsável',
        'ru': 'Войти как родитель',
        'tg': 'Ҳамчун волид ворид шавед',
        'tk': 'Ene-ata hökmünde gir',
        'uz': 'Ota-ona sifatida kirish',
      });

  String get enterInviteCodeError => _pick({
        'ar': 'أدخل رمز الدعوة',
        'az': 'Dəvət kodunu daxil edin',
        'de': 'Gib den Einladungscode ein',
        'en': 'Enter the invite code',
        'es': 'Introduce el código de invitación',
        'fr': "Saisissez le code d'invitation",
        'hy': 'Մուտքագրեք հրավերի կոդը',
        'it': 'Inserisci il codice di invito',
        'ka': 'შეიყვანეთ მოსაწვევის კოდი',
        'kk': 'Шақыру кодын енгізіңіз',
        'ky': 'Чакыруу кодун киргизиңиз',
        'pl': 'Wpisz kod zaproszenia',
        'pt': 'Digite o código de convite',
        'ru': 'Введите код приглашения',
        'tg': 'Рамзи даъватро ворид кунед',
        'tk': 'Çakylyk koduny giriziň',
        'uz': 'Taklif kodini kiriting',
      });

  String get whatsappChatTitle => _pick({
        'ar': 'واتساب: ليو وأليكس',
        'az': 'WhatsApp: Leo və Alex',
        'de': 'WhatsApp: Leo und Alex',
        'en': 'WhatsApp: Leo & Alex',
        'es': 'WhatsApp: Leo y Alex',
        'fr': 'WhatsApp : Leo et Alex',
        'hy': 'WhatsApp․ Leo և Alex',
        'it': 'WhatsApp: Leo e Alex',
        'ka': 'WhatsApp: ლეო და ალექსი',
        'kk': 'WhatsApp: Leo мен Alex',
        'ky': 'WhatsApp: Leo жана Alex',
        'pl': 'WhatsApp: Leo i Alex',
        'pt': 'WhatsApp: Leo e Alex',
        'ru': 'WhatsApp: Лео и Алекс',
        'tg': 'WhatsApp: Leo ва Alex',
        'tk': 'WhatsApp: Leo we Alex',
        'uz': 'WhatsApp: Leo va Alex',
      });

  String monitoringActiveLastSynced(String time) => _fill(
        _pick({
          'ar': 'المراقبة نشطة · آخر مزامنة منذ {time}',
          'az': 'Monitorinq aktivdir · Son sinxronizasiya {time} əvvəl',
          'de': 'Überwachung aktiv · Zuletzt vor {time} synchronisiert',
          'en': 'Monitoring active · Last synced {time} ago',
          'es': 'Monitorización activa · Última sincronización hace {time}',
          'fr': 'Surveillance active · Dernière synchro il y a {time}',
          'hy': 'Դիտարկումն ակտիվ է · Վերջին համաժամեցումը {time} առաջ',
          'it': 'Monitoraggio attivo · Ultima sincronizzazione {time} fa',
          'ka': 'მონიტორინგი აქტიურია · ბოლო სინქრონიზაცია {time} წინ',
          'kk': 'Бақылау белсенді · Соңғы синхрондау {time} бұрын',
          'ky': 'Байкоо активдүү · Акыркы шайкештештирүү {time} мурун',
          'pl': 'Monitoring aktywny · Ostatnia synchronizacja {time} temu',
          'pt': 'Monitoramento ativo · Última sincronização há {time}',
          'ru': 'Мониторинг активен · Последняя синхронизация {time} назад',
          'tg': 'Назорат фаъол аст · Ҳамоҳангсозии охирин {time} пеш',
          'tk': 'Gözegçilik işjeň · Soňky utgaşdyrma {time} öň',
          'uz': 'Monitoring faol · Oxirgi sinxronlash {time} oldin',
        }),
        {'time': time},
      );

  String get safetyScoreUpper => _pick({
        'ar': 'مستوى الأمان',
        'az': 'TƏHLÜKƏSİZLİK XALI',
        'de': 'SICHERHEITSWERT',
        'en': 'SAFETY SCORE',
        'es': 'PUNTUACIÓN DE SEGURIDAD',
        'fr': 'SCORE DE SÉCURITÉ',
        'hy': 'ԱՆՎՏԱՆԳՈՒԹՅԱՆ ԳՆԱՀԱՏԱԿԱՆ',
        'it': 'PUNTEGGIO SICUREZZA',
        'ka': 'უსაფრთხოების ქულა',
        'kk': 'ҚАУІПСІЗДІК БАҒАСЫ',
        'ky': 'КООПСУЗДУК УПАЙЫ',
        'pl': 'WYNIK BEZPIECZEŃSTWA',
        'pt': 'PONTUAÇÃO DE SEGURANÇA',
        'ru': 'ИНДЕКС БЕЗОПАСНОСТИ',
        'tg': 'ХОЛИ АМНИЯТ',
        'tk': 'HOWPSUZLYK BAHASY',
        'uz': 'XAVFSIZLIK BAHOSI',
      });

  String get conversationAnalysis => _pick({
        'ar': 'تحليل المحادثة',
        'az': 'Söhbət təhlili',
        'de': 'Gesprächsanalyse',
        'en': 'Conversation Analysis',
        'es': 'Análisis de la conversación',
        'fr': 'Analyse de la conversation',
        'hy': 'Զրույցի վերլուծություն',
        'it': 'Analisi della conversazione',
        'ka': 'საუბრის ანალიზი',
        'kk': 'Әңгіме талдауы',
        'ky': 'Баарлашууну талдоо',
        'pl': 'Analiza rozmowy',
        'pt': 'Análise da conversa',
        'ru': 'Анализ переписки',
        'tg': 'Таҳлили сӯҳбат',
        'tk': 'Söhbet seljermesi',
        'uz': 'Suhbat tahlili',
      });

  String get conversationAnalysisSummary => _pick({
        'ar':
            'اكتشف الذكاء الاصطناعي نقاشاً بنّاءً حول المسؤوليات الدراسية. التفاعل موثوق ومنخفض المخاطر.',
        'az':
            'Süni intellekt dərs məsuliyyətləri barədə konstruktiv söhbət aşkar etdi. Ünsiyyət etibarlı və aşağı risklidir.',
        'de':
            'Die KI hat eine konstruktive Unterhaltung über schulische Pflichten erkannt. Die Interaktion wirkt vertrauensvoll und risikoarm.',
        'en':
            'AI detected a constructive discussion about academic responsibilities. Interaction remains high-trust and low-risk.',
        'es':
            'La IA detectó una conversación constructiva sobre responsabilidades académicas. La interacción sigue siendo confiable y de bajo riesgo.',
        'fr':
            "L'IA a détecté une discussion constructive sur les responsabilités scolaires. L'échange reste fiable et peu risqué.",
        'hy':
            'ԱԲ-ն հայտնաբերել է կառուցողական քննարկում ուսումնական պարտականությունների մասին։ Շփումը վստահելի է և ցածր ռիսկային։',
        'it':
            'L’IA ha rilevato una discussione costruttiva sulle responsabilità scolastiche. L’interazione resta affidabile e a basso rischio.',
        'ka':
            'AI-მ დააფიქსირა კონსტრუქციული საუბარი სასკოლო პასუხისმგებლობებზე. კომუნიკაცია სანდოა და დაბალი რისკის.',
        'kk':
            'ЖИ оқу міндеттері туралы сындарлы әңгімені анықтады. Қарым-қатынас сенімді және тәуекелі төмен.',
        'ky':
            'ЖИ окуу милдеттери жөнүндө пайдалуу сүйлөшүүнү аныктады. Баарлашуу ишенимдүү жана тобокелдиги төмөн.',
        'pl':
            'AI wykryła konstruktywną rozmowę o obowiązkach szkolnych. Interakcja pozostaje oparta na zaufaniu i niskim ryzyku.',
        'pt':
            'A IA detectou uma conversa construtiva sobre responsabilidades acadêmicas. A interação continua confiável e de baixo risco.',
        'ru':
            'ИИ обнаружил конструктивное обсуждение учебных обязанностей. Общение остаётся доверительным и с низким риском.',
        'tg':
            'Зеҳни сунъӣ муҳокимаи созандаро дар бораи масъулиятҳои дарсӣ муайян кард. Муошират боэътимод ва камхатар аст.',
        'tk':
            'AI okuw jogapkärçilikleri barada oňyn söhbeti anyklady. Aragatnaşyk ynamly we töwekgelçiligi pes bolup galýar.',
        'uz':
            'Sun’iy intellekt o‘quv mas’uliyatlari haqidagi konstruktiv suhbatni aniqladi. Muloqot ishonchli va past xavfli.',
      });

  String get positiveIntent => _pick({
        'ar': 'نية إيجابية',
        'az': 'MÜSBƏT NİYYƏT',
        'de': 'POSITIVE ABSICHT',
        'en': 'POSITIVE INTENT',
        'es': 'INTENCIÓN POSITIVA',
        'fr': 'INTENTION POSITIVE',
        'hy': 'ԴՐԱԿԱՆ ՆՊԱՏԱԿ',
        'it': 'INTENTO POSITIVO',
        'ka': 'დადებითი განზრახვა',
        'kk': 'ОҢ НИЕТ',
        'ky': 'ОҢ НИЕТ',
        'pl': 'POZYTYWNA INTENCJA',
        'pt': 'INTENÇÃO POSITIVA',
        'ru': 'ПОЗИТИВНОЕ НАМЕРЕНИЕ',
        'tg': 'НИЯТИ МУСБАТ',
        'tk': 'OŇYBARA MAKSAT',
        'uz': 'IJOBIY NIYAT',
      });

  String get homeworkLabel => _pick({
        'ar': 'الواجب',
        'az': 'EV TAPŞIRIĞI',
        'de': 'HAUSAUFGABEN',
        'en': 'HOMEWORK',
        'es': 'TAREA',
        'fr': 'DEVOIRS',
        'hy': 'ՏՆԱՅԻՆ ԱՇԽԱՏԱՆՔ',
        'it': 'COMPITI',
        'ka': 'საშინაო დავალება',
        'kk': 'ҮЙ ТАПСЫРМАСЫ',
        'ky': 'ҮЙ ТАПШЫРМАСЫ',
        'pl': 'PRACA DOMOWA',
        'pt': 'LIÇÃO DE CASA',
        'ru': 'ДОМАШНЕЕ ЗАДАНИЕ',
        'tg': 'ВАЗИФАИ ХОНАГӢ',
        'tk': 'ÖÝ IŞI',
        'uz': 'UYGA VAZIFA',
      });

  String get gamingLabel => _pick({
        'ar': 'الألعاب',
        'az': 'OYUN',
        'de': 'GAMING',
        'en': 'GAMING',
        'es': 'VIDEOJUEGOS',
        'fr': 'JEUX',
        'hy': 'ԽԱՂԵՐ',
        'it': 'GIOCHI',
        'ka': 'თამაშები',
        'kk': 'ОЙЫН',
        'ky': 'ОЮН',
        'pl': 'GRY',
        'pt': 'JOGOS',
        'ru': 'ИГРЫ',
        'tg': 'БОЗИҲО',
        'tk': 'OÝUN',
        'uz': 'O‘YINLAR',
      });

  String todayAtTime(String time) => _fill(
        _pick({
          'ar': 'اليوم، {time}',
          'az': 'BU GÜN, {time}',
          'de': 'HEUTE, {time}',
          'en': 'TODAY, {time}',
          'es': 'HOY, {time}',
          'fr': "AUJOURD'HUI, {time}",
          'hy': 'ԱՅՍՕՐ, {time}',
          'it': 'OGGI, {time}',
          'ka': 'დღეს, {time}',
          'kk': 'БҮГІН, {time}',
          'ky': 'БҮГҮН, {time}',
          'pl': 'DZIŚ, {time}',
          'pt': 'HOJE, {time}',
          'ru': 'СЕГОДНЯ, {time}',
          'tg': 'ИМРӮЗ, {time}',
          'tk': 'ŞUGÜN, {time}',
          'uz': 'BUGUN, {time}',
        }),
        {'time': time},
      );

  String get msgHistoryAssignment => _pick({
        'ar': 'مرحباً ليو، هل أنهيت واجب التاريخ للغد؟ إنه ضخم.',
        'az': 'Salam Leo, sabah üçün tarix tapşırığını bitirdin? Çox böyükdür.',
        'de':
            'Hey Leo, hast du die Geschichtsaufgabe für morgen fertig? Die ist riesig.',
        'en':
            'Hey Leo, did you finish the history assignment for tomorrow? It’s huge.',
        'es':
            'Hola Leo, ¿terminaste la tarea de historia para mañana? Es enorme.',
        'fr':
            "Salut Leo, tu as fini le devoir d'histoire pour demain ? Il est énorme.",
        'hy': 'Բարև, Leo, վաղվա պատմության առաջադրանքն ավարտե՞լ ես։ Շատ մեծ է։',
        'it':
            'Ehi Leo, hai finito il compito di storia per domani? È lunghissimo.',
        'ka': 'ჰეი ლეო, ხვალისთვის ისტორიის დავალება დაასრულე? ძალიან დიდია.',
        'kk':
            'Сәлем, Leo, ертеңге берілген тарих тапсырмасын бітірдің бе? Өте үлкен екен.',
        'ky':
            'Салам, Leo, эртеңки тарых тапшырмасын бүтүрдүңбү? Абдан чоң экен.',
        'pl':
            'Hej Leo, skończyłeś już zadanie z historii na jutro? Jest ogromne.',
        'pt':
            'Oi Leo, você terminou a tarefa de história para amanhã? Está enorme.',
        'ru':
            'Привет, Лео, ты закончил задание по истории на завтра? Оно огромное.',
        'tg':
            'Салом, Leo, вазифаи таърихро барои пагоҳ тамом кардӣ? Хеле калон аст.',
        'tk':
            'Salam Leo, ertir üçin taryh tabşyrygyny gutardyňmy? Gaty uly eken.',
        'uz':
            'Salom Leo, ertaga uchun tarix vazifasini tugatdingmi? Juda katta ekan.',
      });

  String get msgAlmostFinish => _pick({
        'ar':
            'تقريباً. بقي فقط جزء الثورة الصناعية. هل تريد أن ندخل ديسكورد بعد ذلك؟',
        'az':
            'Demək olar. Sadəcə sənaye inqilabı hissəsini bitirməliyəm. Sonra Discord-a keçək?',
        'de':
            'Fast. Ich muss nur noch den Teil über die industrielle Revolution fertig machen. Wollen wir danach auf Discord?',
        'en':
            'Almost. Just need to finish the part about the industrial revolution. Want to jump on Discord after?',
        'es':
            'Casi. Solo me falta terminar la parte sobre la revolución industrial. ¿Entramos a Discord después?',
        'fr':
            "Presque. Il me reste juste la partie sur la révolution industrielle. On va sur Discord après ?",
        'hy':
            'Համարյա։ Մնացել է միայն արդյունաբերական հեղափոխության մասը։ Հետո ուզո՞ւմ ես Discord մտնենք։',
        'it':
            'Quasi. Devo solo finire la parte sulla rivoluzione industriale. Poi andiamo su Discord?',
        'ka':
            'თითქმის. მხოლოდ ინდუსტრიული რევოლუციის ნაწილი მაქვს დასასრულებელი. მერე Discord-ზე გადავიდეთ?',
        'kk':
            'Дайын деуге болады. Өнеркәсіптік революция туралы бөлікті ғана аяқтауым керек. Сосын Discord-қа кірейік пе?',
        'ky':
            'Аз калды. Индустриялык революция тууралуу бөлүгүн гана бүтүрүшүм керек. Анан Discord-ка кирелиби?',
        'pl':
            'Prawie. Muszę tylko dokończyć część o rewolucji przemysłowej. Wchodzimy potem na Discorda?',
        'pt':
            'Quase. Só preciso terminar a parte sobre a revolução industrial. Quer entrar no Discord depois?',
        'ru':
            'Почти. Осталось закончить часть про промышленную революцию. Потом зайдём в Discord?',
        'tg':
            'Қариб тамом. Фақат қисми инқилоби саноатиро ба охир расондан лозим. Баъд ба Discord дароем?',
        'tk':
            'Tas diýen ýaly. Diňe senagat öwrülişigi baradaky bölegi gutarmaly. Soň Discord-a geçelimi?',
        'uz':
            'Deyarli. Faqat sanoat inqilobi haqidagi qismini tugatishim qoldi. Keyin Discordga o‘tamizmi?',
      });

  String get msgHomeworkFirst => _pick({
        'ar':
            'أكيد، لكن لننهِ الواجب أولاً حتى لا نقع في مشكلة. أمي تراجع درجاتي اليوم.',
        'az':
            'Olar, amma əvvəl ev tapşırığını edək ki, problem olmasın. Anam bu gün qiymətlərimi yoxlayır.',
        'de':
            'Klar, aber lass uns erst die Hausaufgaben machen, damit wir keinen Ärger bekommen. Meine Mutter schaut sich heute meine Noten an.',
        'en':
            "Sure, but let's do homework first so we don't get in trouble. My mom is checking my grades today.",
        'es':
            'Claro, pero hagamos la tarea primero para no meternos en problemas. Mi mamá está revisando mis notas hoy.',
        'fr':
            "Oui, mais faisons d'abord les devoirs pour éviter les ennuis. Ma mère vérifie mes notes aujourd'hui.",
        'hy':
            'Լավ, բայց նախ տնայինը անենք, որ խնդիր չունենանք։ Մայրս այսօր գնահատականներս է նայում։',
        'it':
            'Certo, ma facciamo prima i compiti così non avremo problemi. Mia madre controlla i miei voti oggi.',
        'ka':
            'კი, მაგრამ ჯერ საშინაო დავალება გავაკეთოთ, რომ პრობლემები არ შეგვექმნას. დღეს დედაჩემი ჩემს ნიშნებს ამოწმებს.',
        'kk':
            'Әрине, бірақ әуелі үй тапсырмасын орындайық, әйтпесе қиындыққа қаламыз. Бүгін анам бағаларымды тексереді.',
        'ky':
            'Макул, бирок адегенде үй тапшырмасын кылалы, болбосо уруш угуп калабыз. Бүгүн апам бааларымды текшерет.',
        'pl':
            'Jasne, ale najpierw zróbmy pracę domową, żeby nie mieć kłopotów. Moja mama dziś sprawdza moje oceny.',
        'pt':
            'Claro, mas vamos fazer a lição primeiro para não termos problema. Minha mãe vai olhar minhas notas hoje.',
        'ru':
            'Конечно, но давай сначала сделаем домашку, чтобы не попасть в неприятности. Мама сегодня проверяет мои оценки.',
        'tg':
            'Хуб, вале аввал вазифаи хонагиро мекунем, то ба мушкил наафтем. Имрӯз модарам баҳоҳоямро мебинад.',
        'tk':
            'Bolýar, ýöne ilki öý işini edeli, kynçylyk bolmasyn. Ejem şu gün bahalarymy barlaýar.',
        'uz':
            'Mayli, lekin avval uy vazifasini qilaylik, muammoga qolmaylik. Bugun onam baholarimni tekshiradi.',
      });

  String keywordLogged(String keyword) => _fill(
        _pick({
          'ar': 'تم تسجيل الكلمة المفتاحية: {keyword}',
          'az': 'AÇAR SÖZ QEYDƏ ALINDI: {keyword}',
          'de': 'SCHLÜSSELWORT ERKANNT: {keyword}',
          'en': 'KEYWORD LOGGED: {keyword}',
          'es': 'PALABRA CLAVE REGISTRADA: {keyword}',
          'fr': 'MOT-CLÉ ENREGISTRÉ : {keyword}',
          'hy': 'ԳՐԱՆՑՎԵԼ Է ԲԱՆԱԼԻ ԲԱՌԸ՝ {keyword}',
          'it': 'PAROLA CHIAVE RILEVATA: {keyword}',
          'ka': 'საკვანძო სიტყვა დაფიქსირდა: {keyword}',
          'kk': 'ТҮЙІН СӨЗ ТІРКЕЛДІ: {keyword}',
          'ky': 'АЧКЫЧ СӨЗ КАТТАЛДЫ: {keyword}',
          'pl': 'WYKRYTO SŁOWO KLUCZOWE: {keyword}',
          'pt': 'PALAVRA-CHAVE REGISTRADA: {keyword}',
          'ru': 'ЗАФИКСИРОВАНО КЛЮЧЕВОЕ СЛОВО: {keyword}',
          'tg': 'КАЛИМАИ КАЛИДӢ САБТ ШУД: {keyword}',
          'tk': 'AÇAR SÖZ HASABA ALNDY: {keyword}',
          'uz': 'KALIT SO‘Z QAYD ETILDI: {keyword}',
        }),
        {'keyword': keyword},
      );

  String get msgSmartMove => _pick({
        'ar': 'تصرف ذكي. سأراسلك عندما أنتهي.',
        'az': 'Ağıllı qərardır. Bitirəndə sənə yazaram.',
        'de': 'Gute Idee. Ich schreibe dir, wenn ich fertig bin.',
        'en': "Smart move. I'll message you when I'm done.",
        'es': 'Buena idea. Te escribo cuando termine.',
        'fr': "Bonne idée. Je t'écris quand j'ai fini.",
        'hy': 'Լավ միտք է։ Ավարտեմ, կգրեմ քեզ։',
        'it': 'Ottima idea. Ti scrivo quando ho finito.',
        'ka': 'კარგი აზრია. როცა დავასრულებ, მოგწერ.',
        'kk': 'Дұрыс шешім. Бітіргенде саған жазамын.',
        'ky': 'Туура ой. Бүткөндө сага жазам.',
        'pl': 'Dobry ruch. Napiszę, gdy skończę.',
        'pt': 'Boa ideia. Te mando mensagem quando eu terminar.',
        'ru': 'Хорошая мысль. Напишу тебе, когда закончу.',
        'tg': 'Қарори хуб. Вақте тамом кардам, ба ту менависам.',
        'tk': 'Gowy pikir. Gutaramda saňa ýazaryn.',
        'uz': 'To‘g‘ri qaror. Tugatganimda senga yozaman.',
      });

  String get secureLabel => _pick({
        'ar': 'آمن',
        'az': 'TƏHLÜKƏSİZ',
        'de': 'SICHER',
        'en': 'SECURE',
        'es': 'SEGURO',
        'fr': 'SÛR',
        'hy': 'ԱՆՎՏԱՆԳ',
        'it': 'SICURO',
        'ka': 'უსაფრთხო',
        'kk': 'ҚАУІПСІЗ',
        'ky': 'КООПСУЗ',
        'pl': 'BEZPIECZNIE',
        'pt': 'SEGURO',
        'ru': 'БЕЗОПАСНО',
        'tg': 'БЕХАТАР',
        'tk': 'HOWPSUZ',
        'uz': 'XAVFSIZ',
      });

  String get messengerSafetyScoreTitle => _pick({
        'ar': 'مؤشر أمان المراسلة',
        'az': 'Messenger Təhlükəsizlik Xalı',
        'de': 'Messenger-Sicherheitswert',
        'en': 'Messenger Safety Score',
        'es': 'Puntuación de seguridad del mensajero',
        'fr': 'Score de sécurité de la messagerie',
        'hy': 'Մեսենջերի անվտանգության գնահատական',
        'it': 'Punteggio sicurezza messaggistica',
        'ka': 'მესენჯერის უსაფრთხოების ქულა',
        'kk': 'Мессенджер қауіпсіздік бағасы',
        'ky': 'Мессенжер коопсуздук упайы',
        'pl': 'Wynik bezpieczeństwa komunikatorów',
        'pt': 'Pontuação de segurança do mensageiro',
        'ru': 'Индекс безопасности мессенджеров',
        'tg': 'Холи амнияти паёмрасон',
        'tk': 'Habarlaşma howpsuzlyk bahasy',
        'uz': 'Messenger xavfsizlik bahosi',
      });

  String get messengerSafetyScoreSummary => _pick({
        'ar':
            'التفاعلات الرقمية لطفلك ضمن الحدود الآمنة حالياً على جميع المنصات.',
        'az':
            'Uşağınızın rəqəmsal ünsiyyəti hazırda bütün platformalarda təhlükəsiz çərçivədədir.',
        'de':
            'Die digitalen Interaktionen deines Kindes liegen derzeit plattformübergreifend im sicheren Bereich.',
        'en':
            "Your child's digital interactions are currently within safe parameters across all platforms.",
        'es':
            'Las interacciones digitales de tu hijo están actualmente dentro de parámetros seguros en todas las plataformas.',
        'fr':
            "Les interactions numériques de votre enfant restent actuellement dans des paramètres sûrs sur toutes les plateformes.",
        'hy':
            'Ձեր երեխայի թվային շփումները այս պահին բոլոր հարթակներում ապահով սահմաններում են։',
        'it':
            'Le interazioni digitali di tuo figlio sono attualmente entro parametri sicuri su tutte le piattaforme.',
        'ka':
            'თქვენი ბავშვის ციფრული კომუნიკაცია ამჟამად ყველა პლატფორმაზე უსაფრთხო ფარგლებშია.',
        'kk':
            'Балаңыздың цифрлық қарым-қатынасы қазір барлық платформаларда қауіпсіз шектерде.',
        'ky':
            'Балаңыздын санариптик баарлашуусу азыр бардык платформаларда коопсуз деңгээлде.',
        'pl':
            'Cyfrowe interakcje Twojego dziecka mieszczą się obecnie w bezpiecznych granicach na wszystkich platformach.',
        'pt':
            'As interações digitais da sua criança estão atualmente dentro de parâmetros seguros em todas as plataformas.',
        'ru':
            'Цифровое общение ребёнка сейчас находится в безопасных пределах на всех платформах.',
        'tg':
            'Муоширати рақамии кӯдаки шумо ҳоло дар ҳамаи платформаҳо дар доираи бехатар аст.',
        'tk':
            'Çagaňyzyň sanly aragatnaşygy häzir ähli platformalarda howpsuz çäklerde.',
        'uz':
            'Farzandingizning raqamli muloqoti hozir barcha platformalarda xavfsiz me’yorlarda.',
      });

  String get liveIntercepts => _pick({
        'ar': 'اعتراضات مباشرة',
        'az': 'Canlı tutmalar',
        'de': 'Live-Abfänge',
        'en': 'Live Intercepts',
        'es': 'Intercepciones en vivo',
        'fr': 'Interceptions en direct',
        'hy': 'Ուղիղ որսումներ',
        'it': 'Intercettazioni live',
        'ka': 'ცოცხალი გადაჭერები',
        'kk': 'Тікелей ұстап алулар',
        'ky': 'Түз эфир кармоолору',
        'pl': 'Przechwycenia na żywo',
        'pt': 'Interceptações ao vivo',
        'ru': 'Перехваты в реальном времени',
        'tg': 'Қабулҳои зинда',
        'tk': 'Göni tutmalar',
        'uz': 'Jonli ushlashlar',
      });

  String get realTime => _pick({
        'ar': 'لحظي',
        'az': 'REAL VAXT',
        'de': 'ECHTZEIT',
        'en': 'REAL-TIME',
        'es': 'EN TIEMPO REAL',
        'fr': 'TEMPS RÉEL',
        'hy': 'ԻՐԱԿԱՆ ԺԱՄԱՆԱԿ',
        'it': 'TEMPO REALE',
        'ka': 'რეალურ დროში',
        'kk': 'НАҚТЫ УАҚЫТ',
        'ky': 'РЕАЛДУУ УБАКЫТ',
        'pl': 'CZAS RZECZYWISTY',
        'pt': 'TEMPO REAL',
        'ru': 'РЕАЛЬНОЕ ВРЕМЯ',
        'tg': 'ВАКТИ ҲАҚИҚӢ',
        'tk': 'HÄZIRKI WAGT',
        'uz': 'REAL VAQT',
      });

  String get safeContent => _pick({
        'ar': 'محتوى آمن',
        'az': 'Təhlükəsiz məzmun',
        'de': 'Sicherer Inhalt',
        'en': 'Safe Content',
        'es': 'Contenido seguro',
        'fr': 'Contenu sûr',
        'hy': 'Անվտանգ բովանդակություն',
        'it': 'Contenuto sicuro',
        'ka': 'უსაფრთხო კონტენტი',
        'kk': 'Қауіпсіз мазмұн',
        'ky': 'Коопсуз мазмун',
        'pl': 'Bezpieczna treść',
        'pt': 'Conteúdo seguro',
        'ru': 'Безопасный контент',
        'tg': 'Мундариҷаи бехатар',
        'tk': 'Howpsuz mazmun',
        'uz': 'Xavfsiz kontent',
      });

  String get piiRequestFlagged => _pick({
        'ar': 'طلب بيانات شخصية · تم التنبيه',
        'az': 'Şəxsi məlumat sorğusu · Qeyd edildi',
        'de': 'PII-Anfrage · Markiert',
        'en': 'PII Request   Flagged',
        'es': 'Solicitud de datos personales · Marcada',
        'fr': 'Demande de données perso · Signalée',
        'hy': 'Անձնական տվյալների հարցում · Նշված է',
        'it': 'Richiesta dati personali · Segnalata',
        'ka': 'პირადი მონაცემების მოთხოვნა · მონიშნულია',
        'kk': 'Жеке дерек сұрауы · Белгіленді',
        'ky': 'Жеке маалымат суранычы · Белгиленди',
        'pl': 'Prośba o dane osobowe · Oznaczono',
        'pt': 'Pedido de dados pessoais · Sinalizado',
        'ru': 'Запрос личных данных · Помечено',
        'tg': 'Дархости маълумоти шахсӣ · Нишон дода шуд',
        'tk': 'Şahsy maglumat soragy · Bellendi',
        'uz': 'Shaxsiy ma’lumot so‘rovi · Belgilandi',
      });

  String get externalLink => _pick({
        'ar': 'رابط خارجي',
        'az': 'Xarici keçid',
        'de': 'Externer Link',
        'en': 'External Link',
        'es': 'Enlace externo',
        'fr': 'Lien externe',
        'hy': 'Արտաքին հղում',
        'it': 'Link esterno',
        'ka': 'გარე ბმული',
        'kk': 'Сыртқы сілтеме',
        'ky': 'Тышкы шилтеме',
        'pl': 'Link zewnętrzny',
        'pt': 'Link externo',
        'ru': 'Внешняя ссылка',
        'tg': 'Пайванди беруна',
        'tk': 'Daşarky baglanyşyk',
        'uz': 'Tashqi havola',
      });

  String get sentimentAnalysis => _pick({
        'ar': 'تحليل المشاعر',
        'az': 'Emosiya təhlili',
        'de': 'Stimmungsanalyse',
        'en': 'Sentiment Analysis',
        'es': 'Análisis de sentimiento',
        'fr': 'Analyse du sentiment',
        'hy': 'Զգացմունքային վերլուծություն',
        'it': 'Analisi del sentiment',
        'ka': 'სენტიმენტის ანალიზი',
        'kk': 'Көңіл-күй талдауы',
        'ky': 'Сезим талдоосу',
        'pl': 'Analiza nastroju',
        'pt': 'Análise de sentimento',
        'ru': 'Анализ тональности',
        'tg': 'Таҳлили эҳсосот',
        'tk': 'Duýgy seljermesi',
        'uz': 'Kayfiyat tahlili',
      });

  String get positiveLabel => _pick({
        'ar': 'إيجابي',
        'az': 'Müsbət',
        'de': 'Positiv',
        'en': 'Positive',
        'es': 'Positivo',
        'fr': 'Positif',
        'hy': 'Դրական',
        'it': 'Positivo',
        'ka': 'დადებითი',
        'kk': 'Оң',
        'ky': 'Оң',
        'pl': 'Pozytywny',
        'pt': 'Positivo',
        'ru': 'Позитив',
        'tg': 'Мусбат',
        'tk': 'Oňyn',
        'uz': 'Ijobiy',
      });

  String get anxiousStressed => _pick({
        'ar': 'قلق أو توتر',
        'az': 'Narahat / stressli',
        'de': 'Ängstlich / gestresst',
        'en': 'Anxious/Stressed',
        'es': 'Ansioso/estresado',
        'fr': 'Anxieux / stressé',
        'hy': 'Անհանգիստ / սթրեսային',
        'it': 'Ansioso / stressato',
        'ka': 'შფოთვა / სტრესი',
        'kk': 'Мазасыз / күйзелген',
        'ky': 'Тынчсыз / стрессте',
        'pl': 'Zestresowany / spięty',
        'pt': 'Ansioso / estressado',
        'ru': 'Тревога / стресс',
        'tg': 'Нигарон / зери стресс',
        'tk': 'Aladaly / stresli',
        'uz': 'Xavotirli / stressda',
      });

  String get sentimentSummary => _pick({
        'ar':
            'المحادثات في الغالب دراسية وعادية. لم يتم رصد أي مؤشرات على تنمر إلكتروني.',
        'az':
            'Söhbətlər əsasən dərs və gündəlik mövzulardadır. Kiberzorakılıq əlaməti aşkarlanmadı.',
        'de':
            'Die Gespräche sind überwiegend schulisch und alltäglich. Es wurden keine Anzeichen von Cybermobbing erkannt.',
        'en':
            'Conversations are mostly academic and casual. No signs of cyberbullying detected.',
        'es':
            'Las conversaciones son mayormente académicas y casuales. No se detectaron señales de ciberacoso.',
        'fr':
            'Les conversations sont surtout scolaires et ordinaires. Aucun signe de cyberharcèlement détecté.',
        'hy':
            'Զրույցները հիմնականում ուսումնական և առօրյա են։ Կիբերբուլիինգի նշաններ չեն հայտնաբերվել։',
        'it':
            'Le conversazioni sono per lo più scolastiche e informali. Nessun segnale di cyberbullismo rilevato.',
        'ka':
            'საუბრები უმეტესად სასწავლო და ყოველდღიურია. კიბერბულინგის ნიშნები არ დაფიქსირდა.',
        'kk':
            'Әңгімелер көбіне оқу мен күнделікті тақырыптар туралы. Кибербуллинг белгілері анықталған жоқ.',
        'ky':
            'Сүйлөшүүлөр негизинен окуу жана жөнөкөй темаларда. Кибербуллинг белгилери табылган жок.',
        'pl':
            'Rozmowy są głównie szkolne i codzienne. Nie wykryto oznak cyberprzemocy.',
        'pt':
            'As conversas são principalmente acadêmicas e casuais. Nenhum sinal de cyberbullying detectado.',
        'ru':
            'Переписки в основном учебные и повседневные. Признаков кибербуллинга не обнаружено.',
        'tg':
            'Сӯҳбатҳо асосан дарсӣ ва оддӣ мебошанд. Нишонаҳои озори интернетӣ ёфт нашуданд.',
        'tk':
            'Söhbetler esasan okuw we gündelik mowzuklarda. Kiberzorlugyň alamatlary tapylmady.',
        'uz':
            'Suhbatlar asosan o‘qish va oddiy mavzularda. Kiberbulling belgilari aniqlanmadi.',
      });

  String get blockedRisks => _pick({
        'ar': 'المخاطر المحظورة',
        'az': 'Bloklanan risklər',
        'de': 'Blockierte Risiken',
        'en': 'BLOCKED RISKS',
        'es': 'RIESGOS BLOQUEADOS',
        'fr': 'RISQUES BLOQUÉS',
        'hy': 'ԱՐԳԵԼԱՓԱԿՎԱԾ ՌԻՍԿԵՐ',
        'it': 'RISCHI BLOCCATI',
        'ka': 'დაბლოკილი რისკები',
        'kk': 'БҰҒАТТАЛҒАН ҚАУІПТЕР',
        'ky': 'БӨГӨТТӨЛГӨН КОРКУНУЧТАР',
        'pl': 'ZABLOKOWANE RYZYKA',
        'pt': 'RISCOS BLOQUEADOS',
        'ru': 'ЗАБЛОКИРОВАННЫЕ РИСКИ',
        'tg': 'ХАТАРҲОИ МАСДУД',
        'tk': 'BLOKLANAN TÖWEKGELLIKLER',
        'uz': 'BLOKLANGAN XAVFLAR',
      });

  String get totalScreenTime => _pick({
        'ar': 'إجمالي وقت الشاشة',
        'az': 'Ümumi ekran vaxtı',
        'de': 'Gesamte Bildschirmzeit',
        'en': 'TOTAL SCREEN TIME',
        'es': 'TIEMPO TOTAL DE PANTALLA',
        'fr': "TEMPS D'ÉCRAN TOTAL",
        'hy': 'ԸՆԴՀԱՆՈՒՐ ԷԿՐԱՆԱՅԻՆ ԺԱՄԱՆԱԿ',
        'it': 'TEMPO SCHERMO TOTALE',
        'ka': 'სულ ეკრანის დრო',
        'kk': 'ЖАЛПЫ ЭКРАН УАҚЫТЫ',
        'ky': 'ЖАЛПЫ ЭКРАН УБАКТЫСЫ',
        'pl': 'ŁĄCZNY CZAS EKRANU',
        'pt': 'TEMPO TOTAL DE TELA',
        'ru': 'ОБЩЕЕ ЭКРАННОЕ ВРЕМЯ',
        'tg': 'ВАҚТИ УМУМИИ ЭКРАН',
        'tk': 'UMUMY EKRAN WAGTY',
        'uz': 'UMUMIY EKRAN VAQTI',
      });

  String get liveAudioStreamingToParent => _pick({
        'ar': 'يتم إرسال الصوت المباشر للوالد...',
        'az': 'Canlı ətraf səsi valideynə ötürülür...',
        'de': 'Live-Umgebungsaudio wird an die Eltern gestreamt...',
        'en': 'Streaming live surrounding audio to parent...',
        'es': 'Transmitiendo audio ambiente en vivo al padre...',
        'fr': "Diffusion de l'audio ambiant en direct au parent...",
        'hy': 'Շրջակա ձայնը ուղիղ փոխանցվում է ծնողին...',
        'it': 'Trasmissione audio ambiente in diretta al genitore...',
        'ka': 'ცოცხალი გარემოს ხმა მშობელს ეგზავნება...',
        'kk': 'Тікелей қоршаған орта дыбысы ата-анаға жіберілуде...',
        'ky': 'Түз эфирдеги айлана-чөйрө үнү ата-энеге жөнөтүлүүдө...',
        'pl': 'Transmisja dźwięku otoczenia na żywo do rodzica...',
        'pt': 'Transmitindo áudio ambiente ao vivo para o responsável...',
        'ru': 'Живая трансляция окружения родителю...',
        'tg': 'Садои муҳит ба таври зинда ба волидайн фиристода мешавад...',
        'tk': 'Göni daşky ses ene-ata iberilýär...',
        'uz': 'Atrofdagi jonli audio ota-onaga uzatilmoqda...',
      });

  String get listeningToSurroundings => _pick({
        'ar': 'الاستماع إلى الأصوات المحيطة...',
        'az': 'Ətraf səsləri dinlənilir...',
        'de': 'Umgebungsgeräusche werden abgehört...',
        'en': 'Listening to surroundings...',
        'es': 'Escuchando el entorno...',
        'fr': "Écoute de l'environnement...",
        'hy': 'Լսում ենք շրջակա ձայները...',
        'it': 'Ascolto dell’ambiente...',
        'ka': 'გარემოს მოსმენა...',
        'kk': 'Қоршаған орта тыңдалып жатыр...',
        'ky': 'Айлана-чөйрө угулуп жатат...',
        'pl': 'Nasłuchiwanie otoczenia...',
        'pt': 'Ouvindo o ambiente...',
        'ru': 'Прослушивание окружения...',
        'tg': 'Гӯш кардани муҳит...',
        'tk': 'Daş-töwerek diňlenýär...',
        'uz': 'Atrof tinglanmoqda...',
      });

  String get menuLabel => _pick({
        'en': 'Menu',
        'ru': 'Меню',
      });

  String get childPermissionsTitle => _pick({
        'en': 'Child permissions',
        'ru': 'Разрешения ребёнка',
      });

  String get tapAvatarToSet => _pick({
        'en': 'Tap the photo to set an avatar.',
        'ru': 'Нажмите на фото, чтобы поставить аватар.',
      });

  String get permissionsTitle => _pick({
        'en': 'Permissions',
        'ru': 'Разрешения',
      });

  String get addChildToSeePermissions => _pick({
        'en': 'Add a child first to see their permissions.',
        'ru': 'Сначала добавьте ребёнка, чтобы увидеть его разрешения.',
      });

  String get statusesNotSyncedYet => _pick({
        'en': 'Statuses have not synced yet',
        'ru': 'Статусы ещё не синхронизированы',
      });

  String lastSyncAt(String time) => _fill(
        _pick({
          'en': 'Last synced: {time}',
          'ru': 'Последняя синхронизация: {time}',
        }),
        {'time': time},
      );

  String get locationEnabledTitle => _pick({
        'en': 'Location enabled',
        'ru': 'Геолокация включена',
      });

  String get locationEnabledDescription => _pick({
        'en': 'Location services on the child phone.',
        'ru': 'Службы геолокации на телефоне ребёнка.',
      });

  String get locationPermissionTitle => _pick({
        'en': 'Location access',
        'ru': 'Доступ к геолокации',
      });

  String get locationPermissionDescription => _pick({
        'en': 'Regular permission to access location.',
        'ru': 'Обычное разрешение на доступ к местоположению.',
      });

  String get backgroundLocationTitle => _pick({
        'en': 'Background location',
        'ru': 'Фоновая геолокация',
      });

  String get backgroundLocationDescription => _pick({
        'en': 'Permission to see the child location in the background.',
        'ru': 'Разрешение видеть местоположение ребёнка в фоне.',
      });

  String get notificationsCommandsDescription => _pick({
        'en': 'Needed for commands, alerts, and signals.',
        'ru': 'Нужно для команд, оповещений и сигналов.',
      });

  String get microphoneTitle => _pick({
        'en': 'Microphone',
        'ru': 'Микрофон',
      });

  String get aroundAudioDescription => _pick({
        'en': 'Needed to listen to audio around the child.',
        'ru': 'Нужно для прослушивания звука вокруг ребёнка.',
      });

  String get usageAccessDescriptionParent => _pick({
        'en': 'Needed for app statistics and screen-time limits.',
        'ru': 'Нужно для статистики приложений и ограничений времени.',
      });

  String get accessibilityDescriptionParent => _pick({
        'en': 'Needed to actually block restricted apps.',
        'ru': 'Нужно, чтобы реально блокировать запрещённые приложения.',
      });

  String get noBatteryRestrictionsTitle => _pick({
        'en': 'No battery restrictions',
        'ru': 'Без ограничений батареи',
      });

  String get noBatteryRestrictionsDescription => _pick({
        'en': 'Helps keep the app from being stopped by Android.',
        'ru': 'Помогает приложению не отключаться системой на Android.',
      });

  String get allowedLabel => _pick({
        'en': 'Allowed',
        'ru': 'Разрешено',
      });

  String get notAllowedLabel => _pick({
        'en': 'Not allowed',
        'ru': 'Не разрешено',
      });

  String get chooseBoyOrGirl => _pick({
        'en': 'Choose: boy or girl.',
        'ru': 'Выберите вариант: сын или дочка.',
      });

  String get enterChildNamePrompt => _pick({
        'en': 'Enter the child name.',
        'ru': 'Введите имя ребёнка.',
      });

  String setupFailed(String error) => _fill(
        _pick({
          'en': 'Could not finish setup: {error}',
          'ru': 'Не удалось завершить настройку: {error}',
        }),
        {'error': error},
      );

  String get codeCopied => _pick({
        'en': 'Code copied.',
        'ru': 'Код скопирован.',
      });

  String inviteShareTextShort(String code) => _fill(
        _pick({
          'en':
              'Install Family Security on the child phone and enter this code: {code}\n\nhttp://89.108.81.151/invite/{code}',
          'ru':
              'Установите Family Security на телефон ребёнка и введите код: {code}\n\nhttp://89.108.81.151/invite/{code}',
        }),
        {'code': code},
      );

  String get familySetupTitle => _pick({
        'en': 'Family setup',
        'ru': 'Настройка семьи',
      });

  String familySetupSubtitle(String name) => _fill(
        _pick({
          'en': 'Let’s quickly connect your child, {name}.',
          'ru': 'Поможем быстро подключить ребёнка, {name}.',
        }),
        {'name': name},
      );

  String get continueLabel => _pick({
        'en': 'Continue',
        'ru': 'Продолжить',
      });

  String get saveNameLabel => _pick({
        'en': 'Save name',
        'ru': 'Сохранить имя',
      });

  String get finishSetupLabel => _pick({
        'en': 'Finish setup',
        'ru': 'Завершить настройку',
      });

  String get nextLabel => _pick({
        'en': 'Next',
        'ru': 'Дальше',
      });

  String get openAppLabel => _pick({
        'en': 'Open app',
        'ru': 'Открыть приложение',
      });

  String get boyOrGirlQuestion => _pick({
        'en': 'Do you have a son or a daughter?',
        'ru': 'У вас сын или дочка?',
      });

  String get familySetupStartSubtitle => _pick({
        'en': 'We’ll start by creating the child profile.',
        'ru': 'С этого начнем создание профиля ребёнка.',
      });

  String get sonLabel => _pick({
        'en': 'Son',
        'ru': 'Сын',
      });

  String get createBoyProfile => _pick({
        'en': 'Create a boy profile',
        'ru': 'Создать профиль мальчика',
      });

  String get daughterLabel => _pick({
        'en': 'Daughter',
        'ru': 'Дочка',
      });

  String get createGirlProfile => _pick({
        'en': 'Create a girl profile',
        'ru': 'Создать профиль девочки',
      });

  String get exampleGirlName => _pick({
        'en': 'Olivia',
        'fr': 'Emma',
        'de': 'Mia',
        'pt': 'Maria',
        'it': 'Sofia',
        'es': 'Sofía',
        'ar': 'عائشة',
        'ru': 'София',
        'pl': 'Zofia',
        'kk': 'Айша',
        'ky': 'Айпери',
        'uz': 'Dilnoza',
        'tg': 'Мадина',
        'tk': 'Gülnara',
        'az': 'Leyla',
        'hy': 'Անահիտ',
        'ka': 'ნინო',
      });

  String get exampleBoyName => _pick({
        'en': 'Liam',
        'fr': 'Gabriel',
        'de': 'Leon',
        'pt': 'João',
        'it': 'Leonardo',
        'es': 'Mateo',
        'ar': 'محمد',
        'ru': 'Александр',
        'pl': 'Jakub',
        'kk': 'Алихан',
        'ky': 'Аман',
        'uz': 'Aziz',
        'tg': 'Фирдавс',
        'tk': 'Merdan',
        'az': 'Murad',
        'hy': 'Արման',
        'ka': 'გიორგი',
      });

  String get nameYourDaughter => _pick({
        'en': 'What is your daughter’s name?',
        'ru': 'Как зовут вашу дочку?',
      });

  String get nameYourSon => _pick({
        'en': 'What is your son’s name?',
        'ru': 'Как зовут вашего сына?',
      });

  String get childSeesNameAfterCode => _pick({
        'en':
            'The child will see this name right after signing in with the code.',
        'ru': 'Это имя сразу увидит ребёнок после входа по коду.',
      });

  String get addPhotoTitle => _pick({
        'en': 'Let’s add a photo',
        'ru': 'Добавим фото',
      });

  String get addPhotoSubtitle => _pick({
        'en':
            'This photo will appear in the child profile. You can skip it and add it later.',
        'ru':
            'Это фото появится в профиле ребёнка. Можно пропустить и добавить позже.',
      });

  String get selectPhotoLabel => _pick({
        'en': 'Choose photo',
        'ru': 'Выбрать фото',
      });

  String get chooseAnotherPhotoLabel => _pick({
        'en': 'Tap to choose another photo',
        'ru': 'Нажмите, чтобы выбрать другое фото',
      });

  String get congratulationsLabel => _pick({
        'en': 'Congratulations!',
        'ru': 'Поздравляем!',
      });

  String get childProfileReady => _pick({
        'en':
            'The child profile is ready. Now connect the child phone with the code.',
        'ru':
            'Профиль ребёнка уже готов. Осталось подключить телефон ребёнка по коду.',
      });

  String get installChildAppTitle => _pick({
        'en': 'Install the app for the child',
        'ru': 'Установите приложение для ребёнка',
      });

  String openChildAppAndEnterCode(String childName) => _fill(
        _pick({
          'en': 'Open the app on {childName}’s phone and enter this code.',
          'ru':
              'Откройте приложение на телефоне {childName} и введите этот код.',
        }),
        {'childName': childName},
      );

  String get numericCodeLabel => _pick({
        'en': 'Numeric code',
        'ru': 'Числовой код',
      });

  String get tapToCopyLabel => _pick({
        'en': 'Tap to copy',
        'ru': 'Нажмите, чтобы скопировать',
      });

  String get inviteChildLabel => _pick({
        'en': 'Invite child',
        'ru': 'Пригласить ребёнка',
      });

  String get childCodeNoLoginPassword => _pick({
        'en':
            'The child phone no longer needs a login and password: just open the app and enter the code.',
        'ru':
            'На телефоне ребёнка теперь не нужен логин и пароль: достаточно открыть приложение и ввести код.',
      });

  String get locationTitle => _pick({
        'en': 'Location',
        'ru': 'Геолокация',
      });

  String get locationGrantedDescription => _pick({
        'en': 'Location access has been granted.',
        'ru': 'Доступ к геолокации выдан.',
      });

  String get locationNotGrantedDescription => _pick({
        'en': 'Location permission has not been granted yet.',
        'ru': 'Разрешение на геолокацию пока не выдано.',
      });

  String get locationServiceOffDescription => _pick({
        'en': 'Location services are currently turned off on this device.',
        'ru': 'Служба геолокации на устройстве сейчас выключена.',
      });

  String get grantAccessLabel => _pick({
        'en': 'Grant access',
        'ru': 'Выдать доступ',
      });

  String get backgroundLocationGrantedDescription => _pick({
        'en': 'Always allowed — location is sent even when the screen is off.',
        'ru':
            'Разрешено «Всегда» — местоположение отправляется даже при выключенном экране.',
      });

  String get backgroundLocationNeedAlwaysDescription => _pick({
        'en':
            'Without “Allow all the time”, Android stops sending coordinates when the screen turns off or the app is minimized. This is the main reason tracking seems to stop working.',
        'ru':
            'Без «Разрешить всегда» Android перестаёт присылать координаты, когда экран гаснет или приложение свёрнуто. Это главная причина, почему отслеживание «перестаёт работать».',
      });

  String get backgroundLocationNeedLocationFirst => _pick({
        'en':
            'First grant normal location permission, then enable “Allow all the time”.',
        'ru':
            'Сначала выдайте обычное разрешение на геолокацию, затем включите «Разрешить всегда».',
      });

  String get allowAllTheTimeLabel => _pick({
        'en': 'Allow all the time',
        'ru': 'Разрешить всегда',
      });

  String get microphoneGrantedDescription => _pick({
        'en': 'Microphone permission has already been granted.',
        'ru': 'Разрешение на микрофон уже выдано.',
      });

  String get microphoneNeededDescription => _pick({
        'en':
            'Without this permission, the Around feature will not be able to hear audio near the child.',
        'ru':
            'Без этого разрешения функция «Вокруг» не сможет слышать звук рядом с ребёнком.',
      });

  String get allowMicrophoneLabel => _pick({
        'en': 'Allow microphone',
        'ru': 'Разрешить микрофон',
      });

  String get notificationsGrantedDescription => _pick({
        'en': 'Notifications are allowed.',
        'ru': 'Уведомления разрешены.',
      });

  String get notificationsNeededDescription => _pick({
        'en':
            'Allow notifications so you do not miss commands and important events.',
        'ru':
            'Разрешите уведомления, чтобы не пропускать команды и важные события.',
      });

  String get allowNotificationsLabel => _pick({
        'en': 'Allow notifications',
        'ru': 'Разрешить уведомления',
      });

  String get usageAccessAlreadyGranted => _pick({
        'en': 'Access to app usage stats has already been granted.',
        'ru': 'Доступ к статистике приложений уже выдан.',
      });

  String get openSettingsLabel => _pick({
        'en': 'Open settings',
        'ru': 'Открыть настройки',
      });

  String get permissionStatusTitle => _pick({
        'en': 'Permission status',
        'ru': 'Статус разрешений',
      });

  String get checkingPermissionsStatus => _pick({
        'en': 'Checking which permissions are already enabled...',
        'ru': 'Проверяем, какие доступы уже включены...',
      });

  String grantedPermissionsCount(int granted, int total) => _fill(
        _pick({
          'en': 'Granted permissions: {granted} of {total}',
          'ru': 'Выдано разрешений: {granted} из {total}',
        }),
        {'granted': granted, 'total': total},
      );

  String get grantedLabel => _pick({
        'en': 'Granted',
        'ru': 'Выдано',
      });

  String get notGrantedLabel => _pick({
        'en': 'Not granted',
        'ru': 'Не выдано',
      });

  String get menuAppearsAfterAddingChild => _pick({
        'en': 'The menu will appear after you add a child',
        'ru': 'Меню появится после добавления ребёнка',
      });

  String get quickAccessLabel => _pick({
        'en': 'Quick access',
        'ru': 'Быстрый доступ',
      });

  String parentPanelLabel(String name) => _fill(
        _pick({
          'en': '{name} panel',
          'ru': 'Панель {name}',
        }),
        {'name': name},
      );

  String get selectedLabel => _pick({
        'en': 'Selected',
        'ru': 'Выбран',
      });

  String get onlineAroundSoundMenuTitle => _pick({
        'en': 'Live audio\naround child',
        'ru': 'Онлайн звук\nвокруг ребенка',
      });

  String get gameLimitsMenuTitle => _pick({
        'en': 'Game limits',
        'ru': 'Лимиты на игры',
      });

  String get incomingChatsMenuTitle => _pick({
        'en': 'Incoming chats',
        'ru': 'Входящие чаты',
      });

  String get mapPlacesMenuTitle => _pick({
        'en': 'Places on map',
        'ru': 'Места на карте',
      });

  String get movementHistoryMenuTitle => _pick({
        'en': 'Movement\nhistory',
        'ru': 'История\nпередвижения',
      });

  String get appStatsMenuTitle => _pick({
        'en': 'App\nstatistics',
        'ru': 'Статистика\nприложений',
      });

  String get childAchievementsMenuTitle => _pick({
        'en': 'Child\nachievements',
        'ru': 'Достижения\nребенка',
      });

  String get loudSignalMenuTitle => _pick({
        'en': 'Loud\nsignal',
        'ru': 'Громкий\nсигнал',
      });

  String get addChildFirstWarning => _pick({
        'en': 'Add a child first.',
        'ru': 'Сначала добавьте ребёнка.',
      });
}
