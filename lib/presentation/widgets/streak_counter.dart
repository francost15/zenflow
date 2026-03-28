import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StreakCounter extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakCounter({
    super.key,
    required this.currentStreak,
    this.longestStreak = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Current streak
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTUAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentStreak',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Longest streak
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAYOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$longestStreak',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
