import 'package:flutter/widgets.dart';

import '../core/constants/app_constants.dart';
import 'generated/app_localizations.dart';

extension AppL10nBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppL10nX on AppLocalizations {
  String themeName(String themeName) {
    switch (themeName) {
      case AppConstants.sapphireLightTheme:
        return lightThemeLabel;
      case AppConstants.sapphireDarkTheme:
      default:
        return darkThemeLabel;
    }
  }

  String languageName(String languageCode) {
    switch (languageCode) {
      case 'bn':
        return banglaLabel;
      case 'en':
      default:
        return englishLabel;
    }
  }
}
