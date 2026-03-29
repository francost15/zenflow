import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/widgets/task_priority_chip.dart';
import 'package:flutter/material.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final Function(bool) onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onUndoDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
    this.onDelete,
    this.onUndoDelete,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.completed;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = _isActive(widget.task) && !isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(widget.task.id),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Tarea eliminada'),
                action: SnackBarAction(
                  label: 'DESHACER',
                  onPressed: () {
                    widget.onUndoDelete?.call();
                  },
                ),
              ),
            ).closed.then((reason) {
              if (reason != SnackBarClosedReason.action) {
                widget.onDelete?.call();
              }
            });
          }
        },
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? AppColors.accent.withAlpha(20) : AppColors.accent.withAlpha(15))
                    : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.onToggle(!isCompleted),
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
                                  color: AppColors.accent.withAlpha(70),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
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
                          widget.task.title,
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
                            TaskPriorityChip(priority: widget.task.priority),
                            if (widget.task.dueTime != null) ...[
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
                                '${widget.task.dueTime!.hour.toString().padLeft(2, '0')}:${widget.task.dueTime!.minute.toString().padLeft(2, '0')}',
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
      widget.onToggle(!isCompleted);
      return false;
    }
    return true;
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
