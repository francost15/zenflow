import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/course/course_overview.dart';
import 'package:app/presentation/screens/courses/course_formatters.dart';
import 'package:app/presentation/screens/courses/widgets/course_detail_components.dart';
import 'package:app/presentation/screens/courses/widgets/course_subject_badge.dart';
import 'package:flutter/material.dart';

class CourseDetailSheet extends StatelessWidget {
  const CourseDetailSheet({
    super.key,
    required this.overview,
    required this.onEdit,
    required this.onDelete,
  });

  final CourseOverview overview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
              CourseSubjectBadge(
                courseName: overview.course.name,
                color: overview.course.color,
                size: 72,
                iconSize: 34,
              ),
              const SizedBox(height: 16),
              Text(
                overview.course.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (overview.course.professor != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        overview.course.professor!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Eliminar materia'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CourseDetailSection(
                icon: Icons.schedule_rounded,
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
              CourseDetailSection(
                icon: Icons.calendar_view_week_rounded,
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
              CourseDetailSection(
                icon: Icons.assignment_rounded,
                title: 'Tareas del curso',
                child: overview.tasks.isEmpty
                    ? Text(
                        'Sin tareas vinculadas. Asigna este curso desde el editor de tareas.',
                        style: theme.textTheme.bodyMedium,
                      )
                    : Column(
                        children: overview.tasks.map((task) {
                          return CourseTaskRow(task: task);
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),
              CourseDetailSection(
                icon: Icons.sticky_note_2_rounded,
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
