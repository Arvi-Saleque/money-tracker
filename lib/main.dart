import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_providers.dart';
import 'features/profile/profile_providers.dart';
import 'features/transactions/transaction_providers.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/shared_preferences_provider.dart';
import 'shared/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  await FirebaseBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MoneyTrackerApp(),
    ),
  );
}

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeName = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    ref.watch(authProfileBootstrapProvider);
    ref.watch(starterDataBootstrapProvider);
    ref.watch(profilePreferencesSyncProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.getTheme(themeName),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
