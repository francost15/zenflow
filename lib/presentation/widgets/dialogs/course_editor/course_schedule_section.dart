import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/course.dart';
import 'package:app/presentation/widgets/dialogs/course_editor/course_time_button.dart';
import 'package:flutter/material.dart';

class ScheduleUpdate {
  const ScheduleUpdate({required this.index, required this.schedule});

  final int index;
  final Schedule schedule;
}

class CourseScheduleSection extends StatelessWidget {
  const CourseScheduleSection({
    super.key,
    required this.schedule,
    required this.onAddSchedule,
    required this.onScheduleChanged,
    required this.onScheduleRemoved,
  });

  final List<Schedule> schedule;
  final VoidCallback onAddSchedule;
  final ValueChanged<ScheduleUpdate> onScheduleChanged;
  final ValueChanged<int> onScheduleRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HORARIO SEMANAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            TextButton.icon(
              onPressed: onAddSchedule,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Añadir bloque'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (schedule.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Agrega al menos un horario si quieres que el hub muestre tu próxima clase.',
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          Column(
            children: List.generate(schedule.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ScheduleEditorCard(
                  schedule: schedule[index],
                  onChanged: (updatedSchedule) {
                    onScheduleChanged(
                      ScheduleUpdate(index: index, schedule: updatedSchedule),
                    );
                  },
                  onRemove: () => onScheduleRemoved(index),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _ScheduleEditorCard extends StatelessWidget {
  const _ScheduleEditorCard({
    required this.schedule,
    required this.onChanged,
    required this.onRemove,
  });

  final Schedule schedule;
  final ValueChanged<Schedule> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: schedule.dayOfWeek,
                  decoration: const InputDecoration(
                    labelText: 'Día',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Lunes')),
                    DropdownMenuItem(value: 2, child: Text('Martes')),
                    DropdownMenuItem(value: 3, child: Text('Miércoles')),
                    DropdownMenuItem(value: 4, child: Text('Jueves')),
                    DropdownMenuItem(value: 5, child: Text('Viernes')),
                    DropdownMenuItem(value: 6, child: Text('Sábado')),
                    DropdownMenuItem(value: 7, child: Text('Domingo')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    onChanged(
                      Schedule(
                        dayOfWeek: value,
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CourseTimeButton(
                  label: 'Inicio',
                  value: schedule.startTime,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: schedule.startTime,
                    );
                    if (picked != null) {
                      onChanged(
                        Schedule(
                          dayOfWeek: schedule.dayOfWeek,
                          startTime: picked,
                          endTime: schedule.endTime,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CourseTimeButton(
                  label: 'Fin',
                  value: schedule.endTime,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: schedule.endTime,
                    );
                    if (picked != null) {
                      onChanged(
                        Schedule(
                          dayOfWeek: schedule.dayOfWeek,
                          startTime: schedule.startTime,
                          endTime: picked,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
