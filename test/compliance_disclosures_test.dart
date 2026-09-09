import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_security/core/widgets/accessibility_disclosure.dart';
import 'package:kid_security/core/widgets/background_location_disclosure.dart';
import 'package:kid_security/core/widgets/microphone_disclosure.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';

void main() {
  group('Google Play Prominent Disclosures Compliance Tests', () {
    testWidgets('AccessibilityDisclosureDialog displays compliant package name disclosure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibilityDisclosureDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tx = ExtraTranslations('en');
      expect(find.text(tx.accessibilityDisclosureTitle), findsOneWidget);
      expect(find.text(tx.accessibilityDisclosureAgree), findsOneWidget);
      expect(find.text(tx.accessibilityDisclosureCancel), findsOneWidget);

      // Verify that disclosure specifically guarantees NO screen text or passwords read
      final bodyText = tx.accessibilityDisclosureBody;
      expect(bodyText.contains('Baby Locator'), isTrue);
      expect(bodyText.contains('does not use AccessibilityService to collect screen text'), isTrue);
    });

    testWidgets('BackgroundLocationDisclosureDialog displays compliant location and address disclosure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BackgroundLocationDisclosureDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tx = ExtraTranslations('en');
      expect(find.text(tx.backgroundLocationDisclosureTitle), findsOneWidget);
      expect(find.text(tx.backgroundLocationDisclosureAgree), findsOneWidget);
      expect(find.text(tx.backgroundLocationDisclosureCancel), findsOneWidget);

      final bodyText = tx.backgroundLocationDisclosureBody;
      expect(bodyText.contains('Baby Locator'), isTrue);
      expect(bodyText.contains('street addresses'), isTrue);
    });

    testWidgets('MicrophoneDisclosureDialog displays compliant live audio and persistent notification disclosure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MicrophoneDisclosureDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tx = ExtraTranslations('en');
      expect(find.text(tx.microphoneDisclosureTitle), findsOneWidget);
      expect(find.text(tx.microphoneDisclosureAgree), findsOneWidget);
      expect(find.text(tx.microphoneDisclosureCancel), findsOneWidget);

      final bodyText = tx.microphoneDisclosureBody;
      expect(bodyText.contains('Baby Locator'), isTrue);
      expect(bodyText.contains('persistent notification'), isTrue);
    });
  });
}
