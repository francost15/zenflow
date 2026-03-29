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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: checkedToday ? null : onCheckIn,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Premium Status Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: checkedToday
                      ? AppColors.success
                      : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: checkedToday
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  checkedToday
                      ? Icons.check_rounded
                      : Icons.local_fire_department_rounded,
                  color: checkedToday
                      ? Colors.white
                      : AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          checkedToday
                              ? '¡COMPLETADO HOY! 🎉'
                              : '${habit.currentStreak} DÍAS DE RACHA',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: checkedToday
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!checkedToday)
                _buildActionButton(
                  icon: Icons.add_rounded,
                  color: AppColors.accent,
                  onPressed: onCheckIn,
                  isDark: isDark,
                ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                onPressed: onDelete,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: color,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
