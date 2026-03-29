import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/widgets/task_priority_chip.dart';
import 'package:app/presentation/widgets/task_tile_helpers.dart';
import 'package:flutter/material.dart';

class TaskTileContent extends StatelessWidget {
  const TaskTileContent({
    super.key,
    required this.task,
    required this.isActive,
    required this.isCompleted,
    required this.isDark,
    required this.onToggle,
  });

  final Task task;
  final bool isActive;
  final bool isCompleted;
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? AppColors.accent.withAlpha(15) : AppColors.accent.withAlpha(10))
            : (isDark ? AppColors.obsidian : Colors.white),
        border: Border.all(
          color: isActive
              ? AppColors.accent.withAlpha(40)
              : (isDark ? AppColors.monolithBorder : Colors.black12),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TaskToggleButton(
            isActive: isActive,
            isCompleted: isCompleted,
            isDark: isDark,
            onTap: onToggle,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
                        : (isDark ? AppColors.stone : theme.colorScheme.onSurface),
                  ),
                ),
                if (!isCompleted) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TaskPriorityChip(priority: task.priority),
                      if (task.dueTime != null) ...[
                        _TaskDueTime(
                          dueTime: task.dueTime!,
                          isDark: isDark,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isCompleted)
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
        ],
      ),
    );
  }
}

class _TaskToggleButton extends StatelessWidget {
  const _TaskToggleButton({
    required this.isActive,
    required this.isCompleted,
    required this.isDark,
    required this.onTap,
  });

  final bool isActive;
  final bool isCompleted;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.accent : Colors.transparent,
          border: Border.all(
            color: isCompleted ? AppColors.accent : (isDark ? AppColors.monolithBorder : Colors.black12),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
          size: 16,
          color: isCompleted ? Colors.white : (isActive ? AppColors.accent : Colors.transparent),
        ),
      ),
    );
  }
}

class _TaskDueTime extends StatelessWidget {
  const _TaskDueTime({
    required this.dueTime,
    required this.isDark,
    required this.theme,
  });

  final TimeOfDay dueTime;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '·',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(Icons.access_time_rounded, size: 12, color: secondaryColor),
        const SizedBox(width: 4),
        Text(
          formatTaskDueTime(dueTime),
          style: theme.textTheme.labelMedium?.copyWith(
            color: secondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
