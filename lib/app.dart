import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/locale_provider.dart';
import 'core/providers/session_providers.dart';
import 'core/services/child_notification_service.dart';
import 'core/services/device_notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/remote_device_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/child/child_root_screen.dart';
import 'features/root/root_screen.dart';
import 'features/sos/sos_alert_screen.dart';

class KidSecurityApp extends ConsumerStatefulWidget {
  const KidSecurityApp({super.key});

  @override
  ConsumerState<KidSecurityApp> createState() => _KidSecurityAppState();
}

class _KidSecurityAppState extends ConsumerState<KidSecurityApp>
    with WidgetsBindingObserver {
  ProviderSubscription<SessionState>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(DeviceNotificationService.instance.initialize());
    unawaited(ChildNotificationService.instance.initialize());

    // Wire SOS callback so FCM foreground handler can show the red screen.
    FcmService.instance.onSosReceived = _showSosScreen;

    _sessionSubscription = ref.listenManual<SessionState>(
      sessionProvider,
      (_, next) => unawaited(_syncNotificationSession(next.user)),
    );

    unawaited(_syncNotificationSession(ref.read(sessionProvider).user));
  }

  void _showSosScreen(String childName, String? message) {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    nav.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SosAlertScreen(
          childName: childName,
          message: message,
        ),
      ),
    );
  }

  Future<void> _syncNotificationSession(SessionUser? user) async {
    if (user != null) {
      await FcmService.instance.registerToken();
    }

    if (user?.role == UserRole.parent) {
      ChildNotificationService.instance.stop();
      await DeviceNotificationService.instance.syncParentSession(user!.id);
      // Stop child background service if we switch to parent.
      await RemoteDeviceService.instance.stop();
    } else if (user?.role == UserRole.child) {
      DeviceNotificationService.instance.stop();
      await ChildNotificationService.instance.start();
      // Start the child background service — it must keep running even
      // when the app is in background or the UI is disposed.
      await RemoteDeviceService.instance.start();
    } else {
      // Logged out — stop everything.
      DeviceNotificationService.instance.stop();
      ChildNotificationService.instance.stop();
      await RemoteDeviceService.instance.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final role = ref.read(sessionProvider).user?.role;
      if (role == UserRole.parent) {
        unawaited(DeviceNotificationService.instance.refreshNow());
      } else if (role == UserRole.child) {
        unawaited(ChildNotificationService.instance.start());
      }
    }
  }

  @override
  void dispose() {
    _sessionSubscription?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final session = ref.watch(sessionProvider);
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      onGenerateTitle: (context) => S.of(context).appName,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      debugShowMaterialGrid: false,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: switch (session.user?.role) {
        UserRole.parent => const RootScreen(),
        UserRole.child => const ChildRootScreen(),
        _ => const OnboardingScreen(),
      },
    );
  }
}
