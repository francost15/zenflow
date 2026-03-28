import 'package:equatable/equatable.dart';
import '../../../domain/entities/course.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class CoursesLoadRequested extends CourseEvent {}

class CourseCreated extends CourseEvent {
  final Course course;

  const CourseCreated(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseUpdated extends CourseEvent {
  final Course course;

  const CourseUpdated(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseDeleted extends CourseEvent {
  final String courseId;

  const CourseDeleted(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class CourseProgressUpdated extends CourseEvent {
  final String courseId;
  final double progress;

  const CourseProgressUpdated({required this.courseId, required this.progress});

  @override
  List<Object?> get props => [courseId, progress];
}
