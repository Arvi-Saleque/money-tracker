import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_tracker/main.dart';
import 'package:money_tracker/shared/providers/shared_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phase 1 shell renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MoneyTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Money Tracker'), findsWidgets);
    expect(find.text('Theme system'), findsOneWidget);
    expect(find.text('Feature placeholders'), findsOneWidget);
  });
}
