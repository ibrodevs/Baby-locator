import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/session_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final container = ProviderContainer();
  await container.read(sessionProvider.notifier).bootstrap();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const KidSecurityApp(),
  ));
}
