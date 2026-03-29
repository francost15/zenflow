import 'package:app/core/constants/app_colors.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/blocs/course/course_overview.dart';
import 'package:app/presentation/screens/courses/course_formatters.dart';
import 'package:flutter/material.dart';

class CourseDetailSheet extends StatelessWidget {
  const CourseDetailSheet({
    super.key,
    required this.overview,
    required this.onEdit,
  });

  final CourseOverview overview;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: overview.course.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      overview.course.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                  ),
                ],
              ),
              if (overview.course.professor != null) ...[
                const SizedBox(height: 8),
                Text(
                  overview.course.professor!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _DetailSection(
                title: 'Próxima clase',
                child: Text(
                  overview.nextClass != null
                      ? formatCourseDateTime(overview.nextClass!.startAt)
                      : 'Sin próxima clase programada',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: 'Horario semanal',
                child: overview.course.schedule.isEmpty
                    ? Text(
                        'Aún no registras horarios para esta materia.',
                        style: theme.textTheme.bodyMedium,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: overview.course.schedule.map((schedule) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              formatScheduleRange(
                                context,
                                dayOfWeek: schedule.dayOfWeek,
                                startTime: schedule.startTime,
                                endTime: schedule.endTime,
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: 'Tareas del curso',
                child: overview.tasks.isEmpty
                    ? Text(
                        'Sin tareas vinculadas. Asigna este curso desde el editor de tareas.',
                        style: theme.textTheme.bodyMedium,
                      )
                    : Column(
                        children: overview.tasks.map((task) {
                          return _TaskRow(task: task);
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: 'Notas',
                child: Text(
                  overview.course.notes?.isNotEmpty == true
                      ? overview.course.notes!
                      : 'Sin notas para este curso.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: AppColors.accent,
              ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? AppColors.success : AppColors.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCourseTaskDue(task),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
