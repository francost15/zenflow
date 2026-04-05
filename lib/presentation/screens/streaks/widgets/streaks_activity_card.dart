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

    // Calculate metrics
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int currentWeekCount = 0;
    int previousWeekCount = 0;
    int totalPerfectDays = 0;

    heatmapData.forEach((date, count) {
      if (count >= 4) totalPerfectDays++; // arbitrary 'perfect day'
      
      final diff = today.difference(date).inDays;
      if (diff >= 0 && diff < 7) {
        currentWeekCount += count;
      } else if (diff >= 7 && diff < 14) {
        previousWeekCount += count;
      }
    });

    final int diffCount = currentWeekCount - previousWeekCount;
    final bool isPositive = diffCount >= 0;
    final String diffText = diffCount == 0 
        ? 'Igual que la semana pasada'
        : '${isPositive ? '+' : ''}$diffCount vs sem. pasada';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Constancia semanal',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$currentWeekCount',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.obsidian,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'hábitos esta sem.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 12,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      diffText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (totalPerfectDays > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  '$totalPerfectDays Días perfectos (4+)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          HeatmapChart(data: heatmapData, weeksToShow: 12),
        ],
      ),
    );
  }
}
