import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/course.dart';
import 'package:app/presentation/widgets/dialogs/course_editor/course_color_palette.dart';
import 'package:app/presentation/widgets/dialogs/course_editor/course_schedule_section.dart';
import 'package:flutter/material.dart';

class CourseEditorForm extends StatelessWidget {
  const CourseEditorForm({
    super.key,
    required this.nameController,
    required this.professorController,
    required this.notesController,
    required this.selectedColor,
    required this.schedule,
    required this.nameError,
    required this.isEditMode,
    required this.colors,
    required this.onNameChanged,
    required this.onColorChanged,
    required this.onAddSchedule,
    required this.onScheduleChanged,
    required this.onScheduleRemoved,
  });

  final TextEditingController nameController;
  final TextEditingController professorController;
  final TextEditingController notesController;
  final Color selectedColor;
  final List<Schedule> schedule;
  final String? nameError;
  final bool isEditMode;
  final List<Color> colors;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<Color> onColorChanged;
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
        TextField(
          controller: nameController,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Nombre de la materia',
            hintStyle: TextStyle(
              color: _hintColor(isDark).withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
            errorText: nameError,
          ),
          autofocus: !isEditMode,
          onChanged: onNameChanged,
        ),
        TextField(
          controller: professorController,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Profesor (opcional)',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: _hintColor(isDark),
            ),
            border: InputBorder.none,
          ),
        ),
        TextField(
          controller: notesController,
          maxLines: 3,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Notas del curso (opcional)',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: _hintColor(isDark),
            ),
            border: InputBorder.none,
          ),
        ),
        const Divider(height: 32),
        const Text(
          'ETIQUETA DE COLOR',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        CourseColorPalette(
          colors: colors,
          selectedColor: selectedColor,
          onColorChanged: onColorChanged,
        ),
        const SizedBox(height: 24),
        CourseScheduleSection(
          schedule: schedule,
          onAddSchedule: onAddSchedule,
          onScheduleChanged: onScheduleChanged,
          onScheduleRemoved: onScheduleRemoved,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

Color _hintColor(bool isDark) {
  return isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
}
