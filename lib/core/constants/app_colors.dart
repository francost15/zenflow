import 'package:flutter/material.dart';

class AppColors {
  // ─── Primary Accent (Stitch: #FA502E) ───
  static const accent = Color(0xFFFA502E);
  static const accentLight = Color(0xFFFF6B47);
  static const accentDark = Color(0xFFD4401F);

  // ─── Blue Accent (sync, active states) ───
  static const accentBlue = Color(0xFF3B82F6);
  static const accentBlueMuted = Color(0xFF2563EB);

  // ─── Success / Green ───
  static const success = Color(0xFF22C55E);
  static const successMuted = Color(0xFF16A34A);

  // ─── Error / Warning ───
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // ─── Dark Mode Palette ───
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceElevated = Color(0xFF222222);
  static const darkBorder = Color(0xFF2A2A2A);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF999999);
  static const darkTextTertiary = Color(0xFF666666);
  static const darkNavBar = Color(0xFF111111);

  // ─── Light Mode Palette ───
  static const lightBackground = Color(0xFFF7F7F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF0F0EE);
  static const lightBorder = Color(0xFFE5E5E3);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF6B6B6B);
  static const lightTextTertiary = Color(0xFF999999);
  static const lightNavBar = Color(0xFFFFFFFF);

  // ─── Heatmap / Streak Tones (orange-red gradient) ───
  static const heatmapEmpty = Color(0xFF2A2A2A);
  static const heatmapLight = Color(0xFFFA502E);
  static const heatmapMedium = Color(0xFFFF6B47);
  static const heatmapDark = Color(0xFFD4401F);
  static const heatmapDarkest = Color(0xFFB33518);

  // Light mode heatmap
  static const heatmapEmptyLight = Color(0xFFE8E8E6);
  static const heatmapLightLight = Color(0xFFFFCDBF);
  static const heatmapMediumLight = Color(0xFFFF8A6A);
  static const heatmapDarkLight = Color(0xFFFA502E);
  static const heatmapDarkestLight = Color(0xFFD4401F);

  // ─── Course Colors ───
  static const courseRed = Color(0xFFFA502E);
  static const courseBlue = Color(0xFF3B82F6);
  static const coursePurple = Color(0xFF8B5CF6);
  static const courseGreen = Color(0xFF22C55E);
  static const courseAmber = Color(0xFFF59E0B);
  static const coursePink = Color(0xFFEC4899);

  static const List<Color> courseColorPalette = [
    courseRed,
    courseBlue,
    coursePurple,
    courseGreen,
    courseAmber,
    coursePink,
  ];
}
