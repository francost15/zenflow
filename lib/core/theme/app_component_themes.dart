import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

ThemeData applyAppComponentThemes(ThemeData theme, {required bool isDark}) {
  return theme.copyWith(
    appBarTheme: _buildAppBarTheme(isDark: isDark),
    cardTheme: _buildCardTheme(isDark: isDark),
    dividerTheme: DividerThemeData(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      thickness: 1,
    ),
    floatingActionButtonTheme: _buildFabTheme(isDark: isDark),
    navigationBarTheme: _buildNavigationBarTheme(isDark: isDark),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: isDark),
    textButtonTheme: _buildTextButtonTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(isDark: isDark),
    dialogTheme: _buildDialogTheme(isDark: isDark),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    checkboxTheme: _buildCheckboxTheme(isDark: isDark),
    snackBarTheme: _buildSnackBarTheme(isDark: isDark),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    ),
  );
}

AppBarTheme _buildAppBarTheme({required bool isDark}) {
  return AppBarTheme(
    backgroundColor: isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground,
    foregroundColor: isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      letterSpacing: -0.5,
    ),
  );
}

CardThemeData _buildCardTheme({required bool isDark}) {
  return CardThemeData(
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  );
}

FloatingActionButtonThemeData _buildFabTheme({required bool isDark}) {
  return FloatingActionButtonThemeData(
    backgroundColor: isDark ? Colors.white : AppColors.darkBackground,
    foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}

NavigationBarThemeData _buildNavigationBarTheme({required bool isDark}) {
  final inactiveColor = isDark
      ? AppColors.darkTextTertiary
      : AppColors.lightTextTertiary;

  return NavigationBarThemeData(
    backgroundColor: isDark ? AppColors.darkNavBar : AppColors.lightNavBar,
    indicatorColor: AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
          letterSpacing: 0.5,
        );
      }
      return TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: inactiveColor,
        letterSpacing: 0.5,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.accent, size: 22);
      }
      return IconThemeData(color: inactiveColor, size: 22);
    }),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    height: 64,
  );
}

ElevatedButtonThemeData _buildElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.3,
      ),
    ),
  );
}

OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  );
}

TextButtonThemeData _buildTextButtonTheme() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
      textStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  );
}

InputDecorationTheme _buildInputDecorationTheme({required bool isDark}) {
  final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
  final fillColor = isDark
      ? AppColors.darkSurfaceElevated
      : AppColors.lightSurfaceElevated;

  return InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    border: _outlineBorder(borderColor),
    enabledBorder: _outlineBorder(borderColor),
    focusedBorder: _outlineBorder(AppColors.accent, width: isDark ? 2 : 1.5),
    hintStyle: TextStyle(
      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
    ),
    labelStyle: TextStyle(
      color: isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

DialogThemeData _buildDialogTheme({required bool isDark}) {
  return DialogThemeData(
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    ),
  );
}

CheckboxThemeData _buildCheckboxTheme({required bool isDark}) {
  return CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? AppColors.accent
          : Colors.transparent;
    }),
    side: BorderSide(
      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );
}

SnackBarThemeData _buildSnackBarTheme({required bool isDark}) {
  return SnackBarThemeData(
    backgroundColor: isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.lightTextPrimary,
    contentTextStyle: TextStyle(
      fontFamily: 'PlusJakartaSans',
      color: isDark ? AppColors.darkTextPrimary : Colors.white,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  );
}

OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}
