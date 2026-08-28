import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/session_providers.dart';
import 'core/services/background_command_service.dart';
import 'core/services/fcm_service.dart';
import 'core/subscriptions/subscription_service.dart';
import 'features/auth/intro_onboarding_screen.dart';

Future<void> _bootstrapApp(ProviderContainer container) async {
  try {
    await container
        .read(appLocaleProvider.notifier)
        .bootstrap()
        .timeout(const Duration(seconds: 3));
  } catch (error, stackTrace) {
    debugPrint('Locale bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await container
        .read(sessionProvider.notifier)
        .bootstrap()
        .timeout(const Duration(seconds: 8));
  } catch (error, stackTrace) {
    debugPrint('Session bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await container
        .read(subscriptionServiceProvider.notifier)
        .bootstrap(user: container.read(sessionProvider).user)
        .timeout(const Duration(seconds: 8));
  } catch (error, stackTrace) {
    debugPrint('Subscription bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    container.read(introSeenProvider.notifier).state =
        prefs.getBool(introSeenKey) ?? false;
  } catch (error) {
    debugPrint('Intro check failed: $error');
  }

  unawaited(_initializeStartupServices());
}

Future<void> _initializeStartupServices() async {
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
    await FcmService.instance.initialize().timeout(const Duration(seconds: 8));
    await initBackgroundCommandService().timeout(const Duration(seconds: 5));
  } catch (error, stackTrace) {
    debugPrint('Startup service initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final container = ProviderContainer();
  try {
    await _bootstrapApp(container);
  } catch (e) {
    debugPrint('Bootstrap error: $e');
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const KidSecurityApp(),
  ));
}
