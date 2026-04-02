import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'shared_preferences_provider.dart';

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final code =
        _preferences.getString(AppConstants.localePreferenceKey) ??
        AppConstants.defaultLanguageCode;
    return Locale(code);
  }

  Future<void> setLocaleCode(String languageCode) async {
    state = Locale(languageCode);
    await _preferences.setString(
      AppConstants.localePreferenceKey,
      languageCode,
    );
  }

  SharedPreferences get _preferences => ref.read(sharedPreferencesProvider);
}
