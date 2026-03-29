import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/widgets/heatmap_chart.dart';
import 'package:flutter/material.dart';

class StreaksActivityCard extends StatelessWidget {
  const StreaksActivityCard({
    super.key,
    required this.heatmapData,
  });

  final Map<DateTime, int> heatmapData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVIDAD RECIENTE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu constancia semanal, de un vistazo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          HeatmapChart(data: heatmapData, weeksToShow: 20),
        ],
      ),
    );
  }
}
