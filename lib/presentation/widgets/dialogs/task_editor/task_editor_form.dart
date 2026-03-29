import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/widgets/dialogs/task_editor/task_editor_fields.dart';
import 'package:app/presentation/widgets/dialogs/task_editor/task_editor_helpers.dart';
import 'package:flutter/material.dart';

class TaskEditorForm extends StatelessWidget {
  const TaskEditorForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDate,
    required this.selectedTime,
    required this.priority,
    required this.selectedCourseId,
    required this.titleError,
    required this.isEditMode,
    required this.onTitleChanged,
    required this.onPriorityChanged,
    required this.onPickDate,
    required this.onPickTime,
    required this.onCourseChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final TaskPriority priority;
  final String? selectedCourseId;
  final String? titleError;
  final bool isEditMode;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final ValueChanged<String?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: '¿En qué vas a enfocarte?',
            hintStyle: TextStyle(
              color: _hintColor(isDark).withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorText: titleError,
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
          onChanged: onTitleChanged,
          autofocus: !isEditMode,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Notas adicionales (opcional)...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: _hintColor(isDark),
            ),
            border: InputBorder.none,
          ),
        ),
        const Divider(height: 32),
        const Text(
          'PARÁMETROS DE ENFOQUE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: TaskPriority.values.map((taskPriority) {
            final isSelected = priority == taskPriority;

            return ChoiceChip(
              label: Text(taskPriority.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onPriorityChanged(taskPriority);
                }
              },
              backgroundColor: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              selectedColor: priorityColor(taskPriority).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? priorityColor(taskPriority)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
              side: BorderSide(
                color: isSelected
                    ? priorityColor(taskPriority)
                    : Colors.transparent,
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TaskSelectionAction(
              icon: Icons.calendar_today_outlined,
              label:
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              onTap: onPickDate,
            ),
            const SizedBox(width: 12),
            TaskSelectionAction(
              icon: Icons.access_time,
              label: selectedTime != null
                  ? selectedTime!.format(context)
                  : 'Sin hora',
              onTap: onPickTime,
            ),
          ],
        ),
        const SizedBox(height: 20),
        TaskCourseSelector(
          selectedCourseId: selectedCourseId,
          onCourseChanged: onCourseChanged,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

Color _hintColor(bool isDark) {
  return isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
}
