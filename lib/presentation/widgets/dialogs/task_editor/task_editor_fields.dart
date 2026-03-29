import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/course/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskSelectionAction extends StatelessWidget {
  const TaskSelectionAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.darkTextTertiary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCourseSelector extends StatelessWidget {
  const TaskCourseSelector({
    super.key,
    required this.selectedCourseId,
    required this.onCourseChanged,
  });

  final String? selectedCourseId;
  final ValueChanged<String?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoaded && state.courses.isNotEmpty) {
          return DropdownButtonFormField<String?>(
            initialValue: selectedCourseId,
            decoration: InputDecoration(
              labelText: 'Curso vinculado',
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sin curso'),
              ),
              ...state.courses.map((overview) {
                return DropdownMenuItem<String?>(
                  value: overview.course.id,
                  child: Text(overview.course.name),
                );
              }),
            ],
            onChanged: onCourseChanged,
          );
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 18,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Crea cursos para poder vincular tareas a una materia.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
