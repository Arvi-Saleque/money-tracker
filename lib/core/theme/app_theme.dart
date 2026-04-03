import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'gradient_colors.dart';
import 'premium_card_style.dart';

abstract final class AppTheme {
  static ThemeData getTheme(String themeName, {String languageCode = 'en'}) {
    switch (themeName) {
      case AppConstants.sapphireLightTheme:
        return _buildTheme(
          languageCode: languageCode,
          brightness: Brightness.light,
          background: AppColors.lightBackground,
          surface: AppColors.lightSurface,
          surfaceSecondary: AppColors.lightSurfaceSecondary,
          primary: AppColors.lightPrimary,
          income: AppColors.lightIncome,
          expense: AppColors.lightExpense,
          textPrimary: AppColors.lightTextPrimary,
          textSecondary: AppColors.lightTextSecondary,
          border: AppColors.lightBorder,
        );
      case AppConstants.sapphireDarkTheme:
      default:
        return _buildTheme(
          languageCode: languageCode,
          brightness: Brightness.dark,
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          surfaceSecondary: AppColors.darkSurfaceSecondary,
          primary: AppColors.darkPrimary,
          income: AppColors.darkIncome,
          expense: AppColors.darkExpense,
          textPrimary: AppColors.darkTextPrimary,
          textSecondary: AppColors.darkTextSecondary,
          border: AppColors.darkBorder,
        );
    }
  }

  static ThemeData _buildTheme({
    required String languageCode,
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceSecondary,
    required Color primary,
    required Color income,
    required Color expense,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
  }) {
    final baseTheme = ThemeData(brightness: brightness, useMaterial3: true);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          secondary: primary,
          error: expense,
          surface: surface,
          onSurface: textPrimary,
          outline: border,
        );

    final localizedTextTheme = languageCode == 'bn'
        ? GoogleFonts.notoSansBengaliTextTheme(baseTheme.textTheme)
        : GoogleFonts.poppinsTextTheme(baseTheme.textTheme);
    final textTheme = localizedTextTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: surfaceSecondary,
        selectedColor: primary.withValues(alpha: 0.18),
        side: BorderSide(color: border),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        GradientColors(
          heroGradient: LinearGradient(
            colors: <Color>[primary, primary.withValues(alpha: 0.72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          chartGradient: LinearGradient(
            colors: <Color>[
              primary.withValues(alpha: 0.28),
              income.withValues(alpha: 0.08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          successGradient: LinearGradient(
            colors: <Color>[income, income.withValues(alpha: 0.66)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        PremiumCardStyle(
          backgroundColor: surface,
          borderColor: border,
          shadowColor: Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.22 : 0.06,
          ),
          radius: 24,
          padding: const EdgeInsets.all(20),
        ),
      ],
    );
  }
}
