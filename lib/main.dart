import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/session_providers.dart';
import 'core/services/background_command_service.dart';
import 'core/services/fcm_service.dart';

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

  runApp(UncontrolledProviderScope(
    container: container,
    child: const KidSecurityApp(),
  ));

  _bootstrapApp(container);
}
