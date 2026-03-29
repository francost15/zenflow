import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:app/presentation/widgets/dialogs/task_editor/task_editor_fields.dart';
import 'package:app/presentation/widgets/dialogs/task_editor/task_editor_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        if (collisionError != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    collisionError!,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
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
        const SizedBox(height: 16),
        _DailyLoadIndicator(selectedDate: selectedDate),
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

class _DailyLoadIndicator extends StatelessWidget {
  const _DailyLoadIndicator({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is! TaskLoaded) return const SizedBox.shrink();

        final tasks = state.tasks.where((t) {
          return t.dueDate.year == selectedDate.year &&
              t.dueDate.month == selectedDate.month &&
              t.dueDate.day == selectedDate.day;
        }).toList();

        if (tasks.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.monolithBorder.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics_outlined,
                  size: 10, color: AppColors.darkTextTertiary),
              const SizedBox(width: 6),
              Text(
                'PROTOCOL: ${tasks.length} SEC_TASKS_DETEKTED',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
