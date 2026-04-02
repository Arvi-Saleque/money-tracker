import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_tracker/core/constants/app_constants.dart';
import 'package:money_tracker/core/theme/app_theme.dart';
import 'package:money_tracker/features/auth/login_screen.dart';
import 'package:money_tracker/features/dashboard/dashboard_screen.dart';
import 'package:money_tracker/l10n/generated/app_localizations.dart';
import 'package:money_tracker/shared/providers/shared_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login screen renders core auth actions', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('dashboard shell renders starter app UI', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          theme: AppTheme.getTheme(AppConstants.sapphireDarkTheme),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Money Tracker'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Available balance'), findsOneWidget);
  });
}
