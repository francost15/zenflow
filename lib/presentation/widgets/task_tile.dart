import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';
import '../../../core/constants/app_colors.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(bool) onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle(!isCompleted);
          return false;
        } else {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Eliminar tarea'),
              content: const Text('¿Estás seguro?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isActive(task) && !isCompleted
                  ? AppColors.accentBlue.withValues(alpha: 0.4)
                  : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Play icon / checkbox
                GestureDetector(
                  onTap: () => onToggle(!isCompleted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.accent
                            : isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : Icons.play_arrow,
                      size: 16,
                      color: isCompleted
                          ? Colors.white
                          : isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _priorityLabel(task.priority).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: _priorityColor(task.priority),
                            ),
                          ),
                          if (task.dueTime != null) ...[
                            Text(
                              ' · ',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                            Text(
                              '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isActive(Task task) {
    final now = DateTime.now();
    if (task.dueTime != null) {
      final taskTime = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
        task.dueTime!.hour,
        task.dueTime!.minute,
      );
      final diff = taskTime.difference(now).inMinutes;
      return diff >= -30 && diff <= 60;
    }
    return false;
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Priority 01';
      case TaskPriority.medium:
        return 'Priority 02';
      case TaskPriority.low:
        return 'Standard';
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.darkTextTertiary;
    }
  }
}
