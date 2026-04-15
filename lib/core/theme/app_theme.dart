import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surfaceLight,
          error: AppColors.danger,
        ),
        dividerColor: AppColors.dividerLight,
        textTheme: _textTheme(AppColors.textPrimaryLight),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surfaceDark,
          error: AppColors.danger,
        ),
        dividerColor: AppColors.dividerDark,
        textTheme: _textTheme(AppColors.textPrimaryDark),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static TextTheme _textTheme(Color baseColor) {
    return TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: baseColor),
      headlineMedium: AppTextStyles.h2.copyWith(color: baseColor),
      titleLarge: AppTextStyles.h3.copyWith(color: baseColor),
      bodyLarge: AppTextStyles.body.copyWith(color: baseColor),
      bodyMedium: AppTextStyles.body.copyWith(color: baseColor),
      labelLarge: AppTextStyles.button.copyWith(color: baseColor),
      bodySmall: AppTextStyles.caption,
    );
  }
}
