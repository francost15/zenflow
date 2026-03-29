import 'package:app/domain/entities/course.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/course_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/course/course_event.dart';
import 'package:app/presentation/blocs/course/course_overview.dart';
import 'package:app/presentation/blocs/course/course_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;
  final TaskRepository _taskRepository;

  CourseBloc(this._courseRepository, this._taskRepository)
    : super(CourseInitial()) {
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
      emit(await _buildLoadedState());
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

  Future<CourseLoaded> _buildLoadedState() async {
    final courses = await _courseRepository.getCourses();
    final tasks = await _taskRepository.getTasks();
    final overviews = _buildCourseOverviews(courses, tasks);
    return CourseLoaded(
      courses: overviews,
      nextUpcomingClass: _findNextUpcomingClass(overviews),
    );
  }

  List<CourseOverview> _buildCourseOverviews(
    List<Course> courses,
    List<Task> tasks,
  ) {
    final now = DateTime.now();
    return courses.map((course) {
      final courseTasks = tasks
          .where((task) => task.courseId == course.id)
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final completedTasks = courseTasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final pendingTasks = courseTasks.length - completedTasks;
      final progress = courseTasks.isEmpty
          ? 0.0
          : completedTasks / courseTasks.length;

      return CourseOverview(
        course: course,
        tasks: courseTasks,
        pendingTasksCount: pendingTasks,
        completedTasksCount: completedTasks,
        derivedProgress: progress,
        nextClass: _findNextClass(course, now),
      );
    }).toList()
      ..sort((a, b) {
        final aDate = a.nextClass?.startAt;
        final bDate = b.nextClass?.startAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
  }

  UpcomingCourseClass? _findNextUpcomingClass(List<CourseOverview> overviews) {
    UpcomingCourseClass? nextClass;
    for (final overview in overviews) {
      final candidate = overview.nextClass;
      if (candidate == null) {
        continue;
      }
      if (nextClass == null || candidate.startAt.isBefore(nextClass.startAt)) {
        nextClass = candidate;
      }
    }
    return nextClass;
  }

  UpcomingCourseClass? _findNextClass(Course course, DateTime now) {
    UpcomingCourseClass? nextClass;
    for (final schedule in course.schedule) {
      final startAt = _nextOccurrenceStart(schedule, now);
      final endAt = DateTime(
        startAt.year,
        startAt.month,
        startAt.day,
        schedule.endTime.hour,
        schedule.endTime.minute,
      );
      final candidate = UpcomingCourseClass(
        course: course,
        schedule: schedule,
        startAt: startAt,
        endAt: endAt,
      );
      if (nextClass == null || candidate.startAt.isBefore(nextClass.startAt)) {
        nextClass = candidate;
      }
    }
    return nextClass;
  }

  DateTime _nextOccurrenceStart(Schedule schedule, DateTime now) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final dayOffset = (schedule.dayOfWeek - now.weekday + 7) % 7;
    var startAt = todayStart.add(Duration(days: dayOffset));
    startAt = DateTime(
      startAt.year,
      startAt.month,
      startAt.day,
      schedule.startTime.hour,
      schedule.startTime.minute,
    );
    var endAt = DateTime(
      startAt.year,
      startAt.month,
      startAt.day,
      schedule.endTime.hour,
      schedule.endTime.minute,
    );

    if (dayOffset == 0 && endAt.isBefore(now)) {
      startAt = startAt.add(const Duration(days: 7));
      endAt = endAt.add(const Duration(days: 7));
    }

    return startAt;
  }
}
