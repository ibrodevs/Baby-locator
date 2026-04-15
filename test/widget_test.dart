import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kid_security/app.dart';

void main() {
  testWidgets('App boots to root', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KidSecurityApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
