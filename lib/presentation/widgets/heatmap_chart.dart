import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HeatmapChart extends StatelessWidget {
  final Map<DateTime, int> data;
  final int weeksToShow;

  const HeatmapChart({super.key, required this.data, this.weeksToShow = 52});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final colors = isDark
        ? [
            AppColors.heatmapEmpty,
            AppColors.heatmapLight.withValues(alpha: 0.3),
            AppColors.heatmapLight.withValues(alpha: 0.5),
            AppColors.heatmapMedium,
            AppColors.heatmapDark,
          ]
        : [
            AppColors.heatmapEmptyLight,
            AppColors.heatmapLightLight,
            AppColors.heatmapMediumLight,
            AppColors.heatmapDarkLight,
            AppColors.heatmapDarkestLight,
          ];

    final startDate = today.subtract(Duration(days: weeksToShow * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildWeeks(startDate, today, colors),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Menos',
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(width: 4),
            for (int i = 0; i < colors.length; i++)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            const SizedBox(width: 4),
            Text(
              'Más',
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildWeeks(DateTime start, DateTime end, List<Color> colors) {
    final weeks = <Widget>[];
    var currentWeekStart = start;

    while (currentWeekStart.weekday != DateTime.sunday) {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 1));
    }

    while (currentWeekStart.isBefore(end) ||
        currentWeekStart.isAtSameMomentAs(end)) {
      weeks.add(
        Column(
          children: List.generate(7, (dayIndex) {
            final date = currentWeekStart.add(Duration(days: dayIndex));
            if (date.isAfter(end)) {
              return const SizedBox(width: 12, height: 12);
            }
            final intensity = _getIntensity(date);
            return Tooltip(
              message:
                  '${date.month}/${date.day}: ${_getTooltipText(intensity)}',
              child: Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: colors[intensity],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      );
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return weeks;
  }

  int _getIntensity(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (data.containsKey(normalizedDate)) {
      return data[normalizedDate]!.clamp(0, 4);
    }
    return 0;
  }

  String _getTooltipText(int intensity) {
    switch (intensity) {
      case 0:
        return 'Sin actividad';
      case 1:
        return '1 hábito';
      case 2:
        return '2 hábitos';
      case 3:
        return '3 hábitos';
      case 4:
        return '4+ hábitos';
      default:
        return 'Sin actividad';
    }
  }
}
