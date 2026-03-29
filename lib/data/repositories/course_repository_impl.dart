import 'package:app/data/datasources/firestore/course_datasource.dart';
import 'package:app/data/models/course_model.dart';
import 'package:app/domain/entities/course.dart';
import 'package:app/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseDatasource _datasource;

  CourseRepositoryImpl(this._datasource);

  @override
  Future<List<Course>> getCourses() async {
    final models = await _datasource.getCourses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final model = CourseModel.fromEntity(course);
    final created = await _datasource.createCourse(model);
    return created.toEntity();
  }

  @override
  Future<Course> updateCourse(Course course) async {
    final model = CourseModel.fromEntity(course);
    final updated = await _datasource.updateCourse(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _datasource.deleteCourse(courseId);
  }

  @override
  Future<void> updateProgress(String courseId, double progress) async {
    await _datasource.updateProgress(courseId, progress);
  }
}
