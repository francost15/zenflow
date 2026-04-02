import 'package:app/data/datasources/firestore/task_datasource.dart';
import 'package:app/data/services/task_calendar_sync_service.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/entities/task_sync_snapshot.dart';
import 'package:app/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _datasource;
  final TaskCalendarSyncService _syncService;

  TaskRepositoryImpl(this._datasource, this._syncService);

  @override
  Future<List<Task>> getTasks() async {
    final models = await _datasource.getTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final models = await _datasource.getTasksByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    return await _syncService.createAndLink(task);
  }

  @override
  Future<Task> updateTask(Task task) async {
    return await _syncService.updateAndSync(task);
  }

  @override
  Future<void> deleteTask(Task task) async {
    await _syncService.deleteAndUnlink(task);
  }

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {
    final updatedTask = task.copyWith(
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      updatedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
  }

  @override
  Future<ReconciliationResult> reconcileUnsyncedTasks() async {
    final models = await _datasource.getPendingSyncTasks();
    final tasks = models.map((m) => m.toEntity()).toList();
    final result = await _syncService.reconcileUnsyncedTasks(tasks);
    return ReconciliationResult(
      syncedTasks: result.syncedTasks,
      failedTasks: result.failedTasks,
    );
  }

  @override
  Future<List<Task>> getTasksByCourse(String courseId) async {
    final models = await _datasource.getTasksByCourse(courseId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskByCalendarEventId(String calendarEventId) async {
    final models = await _datasource.getTasks(includeDeleted: true);
    final matching = models.where((m) => m.calendarEventId == calendarEventId);
    if (matching.isEmpty) return null;
    return matching.first.toEntity();
  }

  @override
  Future<TaskSyncSnapshot> getTaskSyncSnapshot() async {
    final pendingTasks = await _datasource.getPendingSyncTasks();
    if (pendingTasks.isEmpty) {
      return const TaskSyncSnapshot();
    }

    pendingTasks.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    final failedTasks = pendingTasks
        .where((task) => task.calendarSyncStatus == 'failed')
        .toList();
    final latestErrorTask = pendingTasks.firstWhere(
      (task) => task.lastCalendarSyncError != null,
      orElse: () => pendingTasks.first,
    );

    return TaskSyncSnapshot(
      pendingCount: pendingTasks.length,
      failedCount: failedTasks.length,
      lastError: latestErrorTask.lastCalendarSyncError,
      lastAttemptAt: pendingTasks.first.updatedAt,
    );
  }
}
