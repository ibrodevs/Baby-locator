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
    // Initialize Firebase.
    await Firebase.initializeApp();

    // Initialize FCM (push notifications).
    await FcmService.instance.initialize();

    // Configure background service (registers the isolate entry point).
    await initBackgroundCommandService();
  } catch (error, stackTrace) {
    debugPrint('Startup service initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await container.read(appLocaleProvider.notifier).bootstrap();
  } catch (error, stackTrace) {
    debugPrint('Locale bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await container.read(sessionProvider.notifier).bootstrap();
  } catch (error, stackTrace) {
    debugPrint('Session bootstrap failed: $error');
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
