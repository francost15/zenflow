import 'package:app/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<List<Task>> getTasksByDate(DateTime date);
  Future<List<Task>> getTasksByCourse(String courseId);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(Task task);
  Future<void> undoDeleteTask(Task task);
  Future<void> toggleTaskStatus(Task task, bool completed);
  Future<void> syncPendingTasks();
}
