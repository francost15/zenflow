import 'package:app/domain/entities/task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCourseDateTime(DateTime date) {
  return DateFormat('EEEE d MMM · HH:mm', 'es_ES').format(date);
}

String formatCourseTaskDue(Task task) {
  final date = DateFormat('d MMM', 'es_ES').format(task.dueDate);
  if (task.dueTime == null) {
    return 'Entrega el $date';
  }
  return 'Entrega el $date · ${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}';
}

String weekdayLabel(int dayOfWeek) {
  const labels = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };
  return labels[dayOfWeek] ?? 'Día';
}

String formatScheduleRange(
  BuildContext context, {
  required int dayOfWeek,
  required TimeOfDay startTime,
  required TimeOfDay endTime,
}) {
  return '${weekdayLabel(dayOfWeek)} · ${startTime.format(context)} - ${endTime.format(context)}';
}
