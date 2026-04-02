import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/widgets/heatmap_chart.dart';
import 'package:flutter/material.dart';

class StreaksActivityCard extends StatelessWidget {
  const StreaksActivityCard({super.key, required this.heatmapData});

  final Map<DateTime, int> heatmapData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONSTANCIA SEMANAL',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          HeatmapChart(data: heatmapData, weeksToShow: 16),
        ],
      ),
    );
  }
}
