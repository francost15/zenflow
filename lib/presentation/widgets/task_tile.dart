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
    final isActive = _isActive(task) && !isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.horizontal,
        background: _buildDismissBackground(
          alignment: Alignment.centerLeft,
          color: AppColors.success,
          icon: Icons.check_rounded,
        ),
        secondaryBackground: _buildDismissBackground(
          alignment: Alignment.centerRight,
          color: AppColors.error,
          icon: Icons.delete_outline_rounded,
        ),
        confirmDismiss: (direction) async => _handleDismissConfirm(context, direction, isCompleted),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDelete?.call();
          }
        },
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? AppColors.accent.withValues(alpha: 0.1) : AppColors.accent.withValues(alpha: 0.05))
                  : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Premium Checkbox/Play
                GestureDetector(
                  onTap: () => onToggle(!isCompleted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.accent
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
                      size: 20,
                      color: isCompleted
                          ? Colors.white
                          : (isActive ? AppColors.accent : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.2,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _PriorityChip(priority: task.priority),
                          if (task.dueTime != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: Colors.white),
    );
  }

  Future<bool?> _handleDismissConfirm(BuildContext context, DismissDirection direction, bool isCompleted) async {
    if (direction == DismissDirection.startToEnd) {
      onToggle(!isCompleted);
      return false;
    } else {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar tarea'),
          content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
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
}

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _priorityColor(priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _priorityLabel(priority).toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: _priorityColor(priority),
        ),
      ),
    );
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return 'Prioridad Alta';
      case TaskPriority.medium: return 'Prioridad Media';
      case TaskPriority.low: return 'Estándar';
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return AppColors.error;
      case TaskPriority.medium: return AppColors.warning;
      case TaskPriority.low: return AppColors.darkTextTertiary;
    }
  }
}
