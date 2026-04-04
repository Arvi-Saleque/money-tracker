abstract final class AppConstants {
  static const String appName = 'Money Tracker';

  static const String sapphireDarkTheme = 'sapphire_dark';
  static const String sapphireLightTheme = 'sapphire_light';
  static const String emberDarkTheme = 'ember_dark';
  static const String emberLightTheme = 'ember_light';
  static const String themePreferenceKey = 'selected_theme';
  static const String localePreferenceKey = 'selected_locale';
  static const String appLockEnabledPreferenceKey = 'app_lock_enabled';
  static const String appLockPinPreferenceKey = 'app_lock_pin';
  static const String defaultLanguageCode = 'en';
  static const String defaultCurrency = '\u09F3';
  static const String googleWebClientId =
      '116585083047-s8o950mrd9urbobmbgea3peag75dohum.apps.googleusercontent.com';

  static const String homeRoute = '/';
  static const String authRoute = '/auth';
  static const String signUpRoute = '/auth/signup';
  static const String forgotPasswordRoute = '/auth/forgot-password';
  static const String profileRoute = '/profile';
  static const String transactionsRoute = '/transactions';
  static const String calendarRoute = '/calendar';
  static const String reportsRoute = '/reports';
  static const String walletsRoute = '/wallets';
  static const String budgetsRoute = '/budgets';
  static const String goalsRoute = '/goals';
  static const String subscriptionsRoute = '/subscriptions';
  static const String debtsRoute = '/debts';
  static const String exportRoute = '/export';

  static const List<String> availableThemes = <String>[
    sapphireDarkTheme,
    sapphireLightTheme,
    emberDarkTheme,
    emberLightTheme,
  ];

  static const List<String> supportedLanguageCodes = <String>['en', 'bn'];

  static const List<String> supportedCurrencies = <String>[
    '\u09F3',
    '\$',
    '\u20AC',
  ];

  static String normalizeCurrency(String? value) {
    if (value != null && supportedCurrencies.contains(value)) {
      return value;
    }
    return defaultCurrency;
  }

  static String normalizeLanguageCode(String? value) {
    if (value != null && supportedLanguageCodes.contains(value)) {
      return value;
    }
    return defaultLanguageCode;
  }

  static String normalizeThemeName(String? value) {
    if (value != null && availableThemes.contains(value)) {
      return value;
    }
    return sapphireDarkTheme;
  }

  static String themeLabel(String themeName) {
    switch (themeName) {
      case sapphireLightTheme:
        return 'Sapphire Light';
      case emberDarkTheme:
        return 'Ember Dark';
      case emberLightTheme:
        return 'Ember Light';
      case sapphireDarkTheme:
      default:
        return 'Sapphire Dark';
    }
  }

  static bool isDarkThemeName(String themeName) {
    switch (themeName) {
      case sapphireDarkTheme:
      case emberDarkTheme:
        return true;
      default:
        return false;
    }
  }

  static String togglePairFor(String themeName) {
    switch (themeName) {
      case sapphireLightTheme:
        return sapphireDarkTheme;
      case emberDarkTheme:
        return emberLightTheme;
      case emberLightTheme:
        return emberDarkTheme;
      case sapphireDarkTheme:
      default:
        return sapphireLightTheme;
    }
  }
}
