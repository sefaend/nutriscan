import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutriscan_app/app.dart';
import 'package:nutriscan_app/features/auth/data/mock_auth_service.dart';

void main() {
  testWidgets('Sign in leads to home screen, profile tab opens',
      (WidgetTester tester) async {
    await tester.pumpWidget(NutriScanApp(authService: MockAuthService()));

    // Giriş ekranı
    expect(find.text('Sign In'), findsNWidgets(2)); // başlık + buton

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email...'), 'ali@test.com');
    await tester.enterText(find.widgetWithText(TextFormField, '******'), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    // Ana sayfa
    expect(find.textContaining('Hi, ali'), findsOneWidget);
    expect(find.text('Today Searches'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);

    // Profil
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Allergies'), findsOneWidget);
    expect(find.text('Gluten'), findsOneWidget);
  });
}
