import 'package:app/domain/entities/course.dart';
import 'package:app/domain/entities/task.dart';
import 'package:equatable/equatable.dart';

class UpcomingCourseClass extends Equatable {
  final Course course;
  final Schedule schedule;
  final DateTime startAt;
  final DateTime endAt;

  const UpcomingCourseClass({
    required this.course,
    required this.schedule,
    required this.startAt,
    required this.endAt,
  });

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startAt) && now.isBefore(endAt);
  }

  @override
  List<Object?> get props => [course, schedule, startAt, endAt];
}

class CourseOverview extends Equatable {
  final Course course;
  final List<Task> tasks;
  final int pendingTasksCount;
  final int completedTasksCount;
  final double derivedProgress;
  final UpcomingCourseClass? nextClass;

  const CourseOverview({
    required this.course,
    required this.tasks,
    required this.pendingTasksCount,
    required this.completedTasksCount,
    required this.derivedProgress,
    required this.nextClass,
  });

  @override
  List<Object?> get props => [
    course,
    tasks,
    pendingTasksCount,
    completedTasksCount,
    derivedProgress,
    nextClass,
  ];
}
