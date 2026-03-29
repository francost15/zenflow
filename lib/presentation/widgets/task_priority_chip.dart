import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:flutter/material.dart';

class TaskPriorityChip extends StatelessWidget {
  const TaskPriorityChip({
    super.key,
    required this.priority,
  });

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _priorityColor(priority).withAlpha(20),
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
}

String _priorityLabel(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return 'Prioridad Alta';
    case TaskPriority.medium:
      return 'Prioridad Media';
    case TaskPriority.low:
      return 'Estándar';
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
