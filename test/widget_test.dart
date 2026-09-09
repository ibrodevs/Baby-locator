import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_security/app.dart';
import 'package:kid_security/core/providers/session_providers.dart';
import 'package:kid_security/features/auth/onboarding_screen.dart';
import 'package:kid_security/features/auth/parent_auth_screen.dart';
import 'package:kid_security/l10n/app_localizations.dart';

Widget _buildTestApp({required Widget child, required bool isTestMode}) {
  return ProviderScope(
    overrides: [
      testModeProvider.overrideWith((ref) async => isTestMode),
    ],
    child: MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('App boots to root', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KidSecurityApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets(
      'OnboardingScreen displays premium login button when IS_TEST is true',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const OnboardingScreen(),
        isTestMode: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Войти как премиум пользователь'), findsOneWidget);
  });

  testWidgets(
      'OnboardingScreen hides premium login button when IS_TEST is false',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const OnboardingScreen(),
        isTestMode: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Войти как премиум пользователь'), findsNothing);
  });

  testWidgets(
      'ParentAuthScreen displays premium login button when IS_TEST is true',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const ParentAuthScreen(),
        isTestMode: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Войти как премиум пользователь'), findsOneWidget);
  });

  testWidgets(
      'ParentAuthScreen hides premium login button when IS_TEST is false',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const ParentAuthScreen(),
        isTestMode: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Войти как премиум пользователь'), findsNothing);
  });
}

