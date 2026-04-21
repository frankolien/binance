import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final textTheme = AppTypography.build(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
      AppColors.lightTextTertiary,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBase,
      canvasColor: AppColors.lightBase,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandYellow,
        onPrimary: AppColors.lightTextPrimary,
        secondary: AppColors.brandYellow,
        onSecondary: AppColors.lightTextPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.sell,
        onError: Colors.white,
        outline: AppColors.lightLine,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBase,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerColor: AppColors.lightLine,
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ThemeData dark() {
    final textTheme = AppTypography.build(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
      AppColors.darkTextTertiary,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBase,
      canvasColor: AppColors.darkBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandYellow,
        onPrimary: AppColors.darkBase,
        secondary: AppColors.brandYellow,
        onSecondary: AppColors.darkBase,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.sell,
        onError: Colors.white,
        outline: AppColors.darkLine,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBase,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerColor: AppColors.darkLine,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
