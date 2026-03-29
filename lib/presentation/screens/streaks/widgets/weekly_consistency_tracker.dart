import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WeeklyConsistencyTracker extends StatelessWidget {
  final Map<DateTime, int> data;

  const WeeklyConsistencyTracker({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get current week days (starting from Monday)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    
    final weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
    final weekLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = weekDays[index];
        final label = weekLabels[index];
        final isCompleted = (data[day] ?? 0) > 0;
        final isToday = day.isAtSameMomentAs(today);
        final isFuture = day.isAfter(today);

        return Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                color: isToday
                    ? AppColors.accent
                    : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.accent
                    : (isFuture
                        ? Colors.transparent
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05))),
                borderRadius: BorderRadius.circular(8),
                border: isFuture
                    ? Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1,
                      )
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : (isToday && !isCompleted
                      ? Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null),
            ),
          ],
        );
      }),
    );
  }
}
