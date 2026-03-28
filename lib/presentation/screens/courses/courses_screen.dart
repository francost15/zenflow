import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cursos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CourseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: state.courses.length,
                itemBuilder: (context, index) {
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCourseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CourseBloc>(),
        child: const CreateCourseDialog(),
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, dynamic course) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editar curso - pronto disponible')),
    );
  }

  void _showCourseDetails(BuildContext context, dynamic course) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (course.professor != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(course.professor!),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Progreso: '),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: course.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(course.color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(course.progress * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
