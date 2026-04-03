import 'package:intl/intl.dart';

abstract final class LocaleFormatters {
  static const Map<String, String> _banglaDigits = <String, String>{
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static String localeTag(String languageCode) {
    return languageCode == 'bn' ? 'bn_BD' : 'en_US';
  }

  static String formatCurrency(
    double amount,
    String currency,
    String languageCode,
  ) {
    final hasFraction = amount != amount.roundToDouble();
    final formatter = NumberFormat.currency(
      locale: localeTag(languageCode),
      symbol: currency,
      decimalDigits: hasFraction ? 2 : 0,
    );
    return localizeDigits(formatter.format(amount), languageCode);
  }

  static String formatDate(
    DateTime value,
    String pattern,
    String languageCode,
  ) {
    final formatted = DateFormat(pattern, localeTag(languageCode)).format(value);
    return localizeDigits(formatted, languageCode);
  }

  static String formatNumber(num value, String languageCode) {
    return localizeDigits(
      NumberFormat.decimalPattern(localeTag(languageCode)).format(value),
      languageCode,
    );
  }

  static String localizeDigits(String value, String languageCode) {
    if (languageCode != 'bn') {
      return value;
    }

    return value.split('').map((char) => _banglaDigits[char] ?? char).join();
  }
}
