import 'package:app/domain/entities/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<Course> updateCourse(Course course);
  Future<void> deleteCourse(String courseId);
  Future<void> updateProgress(String courseId, double progress);
}
