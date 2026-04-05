import 'package:app/domain/entities/course.dart';
import 'package:app/presentation/blocs/course/course.dart';
import 'package:app/presentation/screens/courses/widgets/course_detail_sheet.dart';
import 'package:app/presentation/screens/courses/widgets/courses_header.dart';
import 'package:app/presentation/screens/courses/widgets/empty_courses_state.dart';
import 'package:app/presentation/screens/courses/widgets/next_class_hero.dart';
import 'package:app/presentation/widgets/app_snackbars.dart';
import 'package:app/presentation/widgets/confirm_delete_dialog.dart';
import 'package:app/presentation/widgets/course_card.dart';
import 'package:app/presentation/widgets/dialogs/create_course_dialog.dart';
import 'package:app/presentation/widgets/error_state.dart';
import 'package:app/presentation/widgets/loading_indicator.dart';
import 'package:app/presentation/widgets/focus_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      body: SafeArea(
        child: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const LoadingIndicator();
            }

            if (state is CourseError) {
              return ErrorState(
                title: 'No pudimos cargar tus materias',
                message: state.message,
                onRetry: _reloadCourses,
              );
            }

            if (state is! CourseLoaded) {
              return const LoadingIndicator();
            }

            if (state.courses.isEmpty) {
              return Center(
                child: EmptyCoursesState(
                  onCreate: _showCreateCourseDialog,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _reloadCourses(),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: [
                  CoursesHeader(onCreateCourse: _showCreateCourseDialog),
                  const SizedBox(height: 20),
                  NextClassHero(nextClass: state.nextUpcomingClass),
                  const SizedBox(height: 24),
                  Column(
                    children: state.courses.map((overview) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: CourseCard(
                          overview: overview,
                          onTap: () => _showCourseDetails(overview),
                          onEdit: () =>
                              _showEditCourseDialog(overview.course),
                          onDelete: () => _confirmDelete(
                            overview.course.id,
                            overview.course.name,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _reloadCourses() {
    context.read<CourseBloc>().add(CoursesLoadRequested());
  }

  void _showCreateCourseDialog() {
    CourseEditorSheet.show(context);
  }

  void _showEditCourseDialog(Course course) {
    CourseEditorSheet.show(context, initialCourse: course);
  }

  void _showCourseDetails(CourseOverview overview) {
    FocusSheetShell.show<void>(
      context: context,
      child: CourseDetailSheet(
        overview: overview,
        onEdit: () {
          Navigator.pop(context);
          _showEditCourseDialog(overview.course);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(overview.course.id, overview.course.name);
        },
      ),
    );
  }

  Future<void> _confirmDelete(String courseId, String courseName) async {
    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: 'Eliminar curso',
      itemName: courseName,
    );
    if (!confirmed || !mounted) {
      return;
    }

    context.read<CourseBloc>().add(CourseDeleted(courseId));
    AppSnackbars.showNotice(context, 'Materia eliminada');
  }
}
