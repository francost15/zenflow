import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import '../../widgets/course_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/dialogs/create_course_dialog.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(CoursesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Asignaturas', style: theme.textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showCreateCourseDialog(context),
                    icon: Icon(
                      Icons.add,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── Course Grid ───
            Expanded(
              child: BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  if (state is CourseError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CourseBloc>().add(CoursesLoadRequested());
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CourseLoaded) {
                    if (state.courses.isEmpty) {
                      return EmptyState(
                        icon: Icons.school,
                        title: 'No hay cursos',
                        subtitle: 'Agrega tus materias para organizarte mejor',
                        action: ElevatedButton.icon(
                          onPressed: () => _showCreateCourseDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Curso'),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CourseBloc>().add(CoursesLoadRequested());
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: state.courses.length + 1, // +1 for "Añadir" card
                        itemBuilder: (context, index) {
                          if (index == state.courses.length) {
                            return _buildAddCard(theme, isDark);
                          }
                          final course = state.courses[index];
                          return CourseCard(
                            course: course,
                            onTap: () => _showCourseDetails(context, course),
                            onEdit: () => _showEditCourseDialog(context, course),
                            onDelete: () =>
                                _confirmDelete(context, course.id, course.name),
                          );
                        },
                      ),
                    );
                  }

                  return Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => _showCreateCourseDialog(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
            // Can't do dashed easily in Flutter, so solid with lighter color
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 24,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añadir',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCourseDialog(BuildContext context) {
    CreateCourseSheet.show(context);
  }

  void _showEditCourseDialog(BuildContext context, dynamic course) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editar curso - pronto disponible')),
    );
  }

  void _showCourseDetails(BuildContext context, dynamic course) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: course.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              if (course.professor != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 8),
                    Text(course.professor!, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Progreso: ', style: theme.textTheme.bodySmall),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(course.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    String courseId,
    String courseName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Curso'),
        content: Text('¿Estás seguro de eliminar "$courseName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<CourseBloc>().add(CourseDeleted(courseId));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
