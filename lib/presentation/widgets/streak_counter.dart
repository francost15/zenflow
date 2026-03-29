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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTUAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$currentStreak',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Longest streak
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MÁXIMO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$longestStreak',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -2,
                    height: 1,
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
