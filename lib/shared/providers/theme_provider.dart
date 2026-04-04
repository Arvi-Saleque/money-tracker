import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'shared_preferences_provider.dart';

final themeProvider = NotifierProvider<ThemeController, String>(
  ThemeController.new,
);

class ThemeController extends Notifier<String> {
  @override
  String build() {
    return _preferences.getString(AppConstants.themePreferenceKey) ??
        AppConstants.sapphireDarkTheme;
  }

  Future<void> setTheme(String themeName) async {
    state = themeName;
    await _preferences.setString(AppConstants.themePreferenceKey, themeName);
  }

  Future<void> toggleTheme() async {
    final nextTheme = AppConstants.togglePairFor(state);
    await setTheme(nextTheme);
  }

  SharedPreferences get _preferences => ref.read(sharedPreferencesProvider);
}
