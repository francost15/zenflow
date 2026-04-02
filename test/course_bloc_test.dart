import 'package:app/domain/entities/course.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/entities/task_sync_snapshot.dart';
import 'package:app/domain/repositories/course_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/course/course_bloc.dart';
import 'package:app/presentation/blocs/course/course_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'CourseDeleted unlinks related tasks before removing the course',
    () async {
      final now = DateTime(2026, 3, 29, 10);
      final courseRepository = _FakeCourseRepository();
      final taskRepository = _FakeTaskRepository(
        tasks: [
          Task(
            id: 'task-1',
            title: 'Resolver práctica',
            dueDate: now,
            courseId: 'course-1',
            createdAt: now,
            updatedAt: now,
          ),
          Task(
            id: 'task-2',
            title: 'Repasar apuntes',
            dueDate: now,
            courseId: 'course-1',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      final bloc = CourseBloc(courseRepository, taskRepository);

      bloc.add(const CourseDeleted('course-1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(courseRepository.deletedCourseIds, ['course-1']);
      expect(taskRepository.updatedTasks, hasLength(2));
      expect(
        taskRepository.updatedTasks.every((task) => task.courseId == null),
        isTrue,
      );

      await bloc.close();
    },
  );
}

class _FakeCourseRepository implements CourseRepository {
  final List<String> deletedCourseIds = [];

  @override
  Future<Course> createCourse(Course course) async => course;

  @override
  Future<void> deleteCourse(String courseId) async {
    deletedCourseIds.add(courseId);
  }

  @override
  Future<List<Course>> getCourses() async => const [];

  @override
  Future<void> updateProgress(String courseId, double progress) async {}

  @override
  Future<Course> updateCourse(Course course) async => course;
}

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository({required this.tasks});

  final List<Task> tasks;
  final List<Task> updatedTasks = [];

  @override
  Future<Task> createTask(Task task) async => task;

  @override
  Future<void> deleteTask(Task task) async {}

  @override
  Future<List<Task>> getTasks() async => tasks;

  @override
  Future<List<Task>> getTasksByCourse(String courseId) async {
    return tasks.where((task) => task.courseId == courseId).toList();
  }

  @override
  Future<TaskSyncSnapshot> getTaskSyncSnapshot() async {
    return const TaskSyncSnapshot();
  }

  @override
  Future<Task?> getTaskByCalendarEventId(String calendarEventId) async {
    for (final task in tasks) {
      if (task.calendarEventId == calendarEventId) {
        return task;
      }
    }
    return null;
  }

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async => const [];

  @override
  Future<ReconciliationResult> reconcileUnsyncedTasks() async {
    return const ReconciliationResult(syncedTasks: [], failedTasks: []);
  }

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {}

  @override
  Future<Task> updateTask(Task task) async {
    updatedTasks.add(task);
    return task;
  }
}
