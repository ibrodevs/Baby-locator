import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/session_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/role_select_screen.dart';
import 'features/child/child_home_screen.dart';
import 'features/root/root_screen.dart';

class KidSecurityApp extends ConsumerWidget {
  const KidSecurityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return MaterialApp(
      title: 'Kid Security',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: switch (session.user?.role) {
        UserRole.parent => const RootScreen(),
        UserRole.child => const ChildHomeScreen(),
        _ => const RoleSelectScreen(),
      },
    );
  }
}
