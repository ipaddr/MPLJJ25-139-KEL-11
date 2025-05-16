import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:your_app/screens/auth/login_screen.dart';
import 'package:your_app/providers/auth_provider.dart';

void main() {
  testWidgets('LoginScreen has email and password fields and a button', (
    WidgetTester tester,
  ) async {
    // Wrap LoginScreen dengan provider agar dependency terpenuhi
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Cek keberadaan field Email
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    // Cek keberadaan tombol Sign In
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

    // Simulasi input email dan password
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );

    // Tekan tombol Sign In
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    // Setelah tekan tombol, loading indicator muncul (karena _isLoading true)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
