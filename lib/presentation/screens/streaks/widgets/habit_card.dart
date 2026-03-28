import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool checkedToday;
  final VoidCallback onCheckIn;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.checkedToday,
    required this.onCheckIn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: checkedToday
              ? AppColors.success.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: InkWell(
        onTap: checkedToday ? null : onCheckIn,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: checkedToday
                      ? AppColors.success
                      : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  checkedToday
                      ? Icons.check
                      : Icons.local_fire_department,
                  color: checkedToday
                      ? Colors.white
                      : AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkedToday
                          ? '¡Completado hoy! 🎉'
                          : '${habit.currentStreak} días de racha',
                      style: TextStyle(
                        color: checkedToday
                            ? AppColors.success
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!checkedToday)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    color: AppColors.accent,
                    onPressed: onCheckIn,
                    padding: EdgeInsets.zero,
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
