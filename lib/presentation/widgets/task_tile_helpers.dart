import 'package:app/domain/entities/task.dart';
import 'package:flutter/material.dart';

String formatTaskDueTime(TimeOfDay dueTime) {
  return '${dueTime.hour.toString().padLeft(2, '0')}:'
      '${dueTime.minute.toString().padLeft(2, '0')}';
}

bool isTaskActive(Task task, {DateTime? now}) {
  final dueTime = task.dueTime;
  if (dueTime == null) {
    return false;
  }

  final referenceTime = now ?? DateTime.now();
  final scheduledTime = DateTime(
    task.dueDate.year,
    task.dueDate.month,
    task.dueDate.day,
    dueTime.hour,
    dueTime.minute,
  );

  final diffInMinutes = scheduledTime.difference(referenceTime).inMinutes;
  return diffInMinutes >= -30 && diffInMinutes <= 60;
}
