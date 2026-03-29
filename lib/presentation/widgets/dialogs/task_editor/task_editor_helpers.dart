import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:flutter/material.dart';

String buildTaskMutationErrorMessage({
  required bool isDeleting,
  required String error,
}) {
  if (isDeleting) {
    return 'No se pudo eliminar la tarea. Intenta de nuevo.';
  }
  if (error.contains('ALREADY_EXISTS') || error.contains('already-exists')) {
    return 'Esta tarea ya existe.';
  }
  if (error.contains('PERMISSION_DENIED') ||
      error.contains('permission-denied')) {
    return 'No tienes permiso para guardar esta tarea.';
  }
  return 'No se pudo guardar la tarea. Intenta de nuevo.';
}

Color priorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return AppColors.error;
    case TaskPriority.medium:
      return AppColors.courseAmber;
    case TaskPriority.low:
      return AppColors.darkTextTertiary;
  }
}
