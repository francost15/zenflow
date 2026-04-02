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

Task? findCollision({
  required List<Task> existingTasks,
  required DateTime date,
  required TimeOfDay? time,
  String? excludeTaskId,
}) {
  if (time == null) {
    return null;
  }

  for (final task in existingTasks) {
    if (task.id == excludeTaskId) {
      continue;
    }

    final isSameDay = task.dueDate.year == date.year &&
        task.dueDate.month == date.month &&
        task.dueDate.day == date.day;

    final isSameTime = task.dueTime?.hour == time.hour &&
        task.dueTime?.minute == time.minute;

    if (isSameDay && isSameTime) {
      return task;
    }
  }

  return null;
}

String? collisionErrorFor({
  required List<Task> existingTasks,
  required DateTime date,
  required TimeOfDay? time,
  String? excludeTaskId,
}) {
  final collidingTask = findCollision(
    existingTasks: existingTasks,
    date: date,
    time: time,
    excludeTaskId: excludeTaskId,
  );
  return collidingTask == null ? null : formatCollisionError(collidingTask);
}

String formatCollisionError(Task collidingTask) {
  final timeStr = collidingTask.dueTime != null
      ? '${collidingTask.dueTime!.hour.toString().padLeft(2, '0')}:${collidingTask.dueTime!.minute.toString().padLeft(2, '0')}'
      : 'TIME_UNKNOWN';

  return 'CONFLICT: $timeStr - ${collidingTask.title.toUpperCase()}';
}

Task buildTaskFromDraft({
  required Task? initialTask,
  required String title,
  required String? description,
  required DateTime dueDate,
  required TimeOfDay? dueTime,
  required TaskPriority priority,
  required String? courseId,
  required DateTime now,
}) {
  if (initialTask == null) {
    return Task(
      id: '',
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: dueTime,
      priority: priority,
      status: TaskStatus.pending,
      courseId: courseId,
      createdAt: now,
      updatedAt: now,
    );
  }

  return initialTask.copyWith(
    title: title,
    description: description,
    dueDate: dueDate,
    dueTime: dueTime,
    priority: priority,
    courseId: courseId,
    updatedAt: now,
  );
}
