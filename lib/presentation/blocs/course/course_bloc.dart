import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc(this._courseRepository) : super(CourseInitial()) {
    on<CoursesLoadRequested>(_onLoadRequested);
    on<CourseCreated>(_onCreated);
    on<CourseUpdated>(_onUpdated);
    on<CourseDeleted>(_onDeleted);
    on<CourseProgressUpdated>(_onProgressUpdated);
  }

  Future<void> _onLoadRequested(
    CoursesLoadRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    try {
      final courses = await _courseRepository.getCourses();
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onCreated(
    CourseCreated event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await _courseRepository.createCourse(event.course);
      add(CoursesLoadRequested());
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onUpdated(
    CourseUpdated event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await _courseRepository.updateCourse(event.course);
      add(CoursesLoadRequested());
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onDeleted(
    CourseDeleted event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await _courseRepository.deleteCourse(event.courseId);
      add(CoursesLoadRequested());
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  Future<void> _onProgressUpdated(
    CourseProgressUpdated event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await _courseRepository.updateProgress(event.courseId, event.progress);
      add(CoursesLoadRequested());
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
}
