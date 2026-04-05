import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/widgets/dialogs/task_editor/daily_load_indicator.dart';
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
    this.collisionError,
    this.warnings = const [],
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
  final String? collisionError;
  final List<String> warnings;
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
        if (collisionError != null)
          _buildBanner(
            text: collisionError!,
            color: AppColors.error,
            icon: Icons.warning_amber_rounded,
          ),
        ...warnings.map((w) => _buildBanner(
              text: w,
              color: AppColors.courseAmber,
              icon: Icons.info_outline_rounded,
            )),
        if (collisionError != null || warnings.isNotEmpty)
          const SizedBox(height: 16),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: onTitleChanged,
          autofocus: !isEditMode,
        ),
        const SizedBox(height: 16),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Parámetros de enfoque',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskPriority.values.map((p) {
            final isSelected = priority == p;
            return GestureDetector(
              onTap: () => onPriorityChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? priorityColor(p).withValues(alpha: 0.15)
                      : (isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isSelected
                        ? priorityColor(p)
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ),
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
        const SizedBox(height: 16),
        DailyLoadIndicator(selectedDate: selectedDate),
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

Widget _buildBanner({
  required String text,
  required Color color,
  required IconData icon,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    ),
  );
}
