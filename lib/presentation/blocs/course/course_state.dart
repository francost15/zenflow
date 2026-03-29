import 'package:app/presentation/blocs/course/course_overview.dart';
import 'package:equatable/equatable.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<CourseOverview> courses;
  final UpcomingCourseClass? nextUpcomingClass;

  const CourseLoaded({
    required this.courses,
    this.nextUpcomingClass,
  });

  @override
  List<Object?> get props => [courses, nextUpcomingClass];
}

class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}
