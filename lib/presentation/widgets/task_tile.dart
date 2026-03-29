import 'dart:async';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:app/presentation/widgets/task_tile_content.dart';
import 'package:app/presentation/widgets/task_tile_helpers.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = isTaskActive(widget.task) && !isCompleted;

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
        confirmDismiss: (direction) async =>
            _handleDismissConfirm(context, direction, isCompleted),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            Timer(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              AppSnackbars.showAction(
                context,
                'Tarea eliminada',
                actionLabel: 'DESHACER',
                onAction: () => widget.onUndoDelete?.call(),
              ).closed.then((reason) {
                if (reason != SnackBarClosedReason.action) {
                  widget.onDelete?.call();
                }
              });
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
            child: TaskTileContent(
              task: widget.task,
              isActive: isActive,
              isCompleted: isCompleted,
              isDark: isDark,
              onToggle: () => widget.onToggle(!isCompleted),
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
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(50), width: 1),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Future<bool?> _handleDismissConfirm(
    BuildContext context,
    DismissDirection direction,
    bool isCompleted,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      widget.onToggle(!isCompleted);
      return false;
    }
    return true;
  }
}
