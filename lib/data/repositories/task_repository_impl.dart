import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firestore/task_datasource.dart';
import '../services/task_calendar_sync_service.dart';

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
    final models = await _datasource.getTasksWithoutCalendarEvent();
    final tasks = models.map((m) => m.toEntity()).toList();
    return _syncService.reconcileUnsyncedTasks(tasks);
  }
}
