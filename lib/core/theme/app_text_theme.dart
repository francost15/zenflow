import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

TextTheme buildAppTextTheme({required bool isDark}) {
  final primary = isDark
      ? AppColors.darkTextPrimary
      : AppColors.lightTextPrimary;
  final secondary = isDark
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;
  final tertiary = isDark
      ? AppColors.darkTextTertiary
      : AppColors.lightTextTertiary;

  return TextTheme(
    displayLarge: _textStyle(64, FontWeight.w800, primary,
        letterSpacing: -2, height: 1.0),
    displayMedium: _textStyle(48, FontWeight.w700, primary,
        letterSpacing: -1.5, height: 1.1),
    displaySmall: _textStyle(36, FontWeight.w700, primary,
        letterSpacing: -1, height: 1.1),
    headlineLarge: _textStyle(28, FontWeight.w700, primary, letterSpacing: -0.5),
    headlineMedium: _textStyle(24, FontWeight.w700, primary, letterSpacing: -0.5),
    headlineSmall: _textStyle(20, FontWeight.w600, primary),
    titleLarge: _textStyle(18, FontWeight.w600, primary),
    titleMedium: _textStyle(16, FontWeight.w600, primary),
    titleSmall: _textStyle(14, FontWeight.w600, primary),
    bodyLarge: _textStyle(16, FontWeight.w400, primary),
    bodyMedium: _textStyle(14, FontWeight.w400, primary),
    bodySmall: _textStyle(12, FontWeight.w400, secondary),
    labelLarge: _textStyle(14, FontWeight.w600, primary, letterSpacing: 0.5),
    labelMedium: _textStyle(12, FontWeight.w500, secondary, letterSpacing: 0.8),
    labelSmall: _textStyle(10, FontWeight.w700, tertiary, letterSpacing: 1.5),
  );
}

TextStyle _textStyle(
  double fontSize,
  FontWeight fontWeight,
  Color color, {
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}
