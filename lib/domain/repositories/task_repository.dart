import 'package:app/domain/entities/task.dart';
import 'package:app/domain/entities/task_sync_snapshot.dart';

class ReconciliationResult {
  const ReconciliationResult({
    required this.syncedTasks,
    required this.failedTasks,
  });

  final List<Task> syncedTasks;
  final List<Task> failedTasks;
}

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<List<Task>> getTasksByDate(DateTime date);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(Task task);
  Future<void> toggleTaskStatus(Task task, bool completed);
  Future<ReconciliationResult> reconcileUnsyncedTasks();
  Future<List<Task>> getTasksByCourse(String courseId);
  Future<Task?> getTaskByCalendarEventId(String calendarEventId);
  Future<TaskSyncSnapshot> getTaskSyncSnapshot();
}
