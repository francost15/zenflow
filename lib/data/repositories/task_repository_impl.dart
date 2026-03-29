import 'package:app/core/error/exceptions.dart';
import 'package:app/data/datasources/firestore/task_datasource.dart';
import 'package:app/data/models/task_model.dart';
import 'package:app/data/repositories/task_repository_sync.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._datasource, CalendarRepository calendarRepository)
      : _calendarRepository = calendarRepository,
        _syncDelegate = TaskRepositorySyncDelegate(
          _datasource,
          calendarRepository,
        );

  final TaskDatasource _datasource;
  final CalendarRepository _calendarRepository;
  final TaskRepositorySyncDelegate _syncDelegate;

  @override
  Future<List<Task>> getTasks() async => _toEntities(await _datasource.getTasks());

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async =>
      _toEntities(await _datasource.getTasksByDate(date));

  @override
  Future<List<Task>> getTasksByCourse(String courseId) async =>
      _toEntities(await _datasource.getTasksByCourse(courseId));

  @override
  Future<Task> createTask(Task task) async {
    final now = DateTime.now();
    final localTask = task.copyWith(
      updatedAt: now,
      isDeleted: false,
      pendingCalendarSyncAction: null,
      calendarSyncStatus: CalendarSyncStatus.synced,
      lastCalendarSyncError: null,
    );
    final created = await _datasource.createTask(TaskModel.fromEntity(localTask));

    return _syncDelegate.syncTaskImmediately(
      created.toEntity(),
      preferredAction: CalendarSyncAction.create,
      unauthorizedMessage:
          'La tarea se guardo, pero Google Calendar no esta conectado.',
      failureMessage:
          'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
    );
  }

  @override
  Future<Task> updateTask(Task task) async {
    final localTask = task.copyWith(
      isDeleted: false,
      pendingCalendarSyncAction:
          task.pendingCalendarSyncAction == CalendarSyncAction.create
              ? CalendarSyncAction.create
              : null,
      calendarSyncStatus:
          task.pendingCalendarSyncAction == CalendarSyncAction.create
              ? CalendarSyncStatus.pending
              : CalendarSyncStatus.synced,
      lastCalendarSyncError: null,
    );
    final updated = await _datasource.updateTask(TaskModel.fromEntity(localTask));

    return _syncDelegate.syncTaskImmediately(
      updated.toEntity(),
      preferredAction: _syncDelegate.effectiveUpsertAction(task),
      unauthorizedMessage:
          'La tarea se actualizo localmente. La sincronizacion con Google Calendar queda pendiente.',
      failureMessage:
          'La tarea se actualizo localmente, pero no se pudo sincronizar con Google Calendar.',
    );
  }

  @override
  Future<void> deleteTask(Task task) async {
    if (task.calendarEventId == null ||
        task.pendingCalendarSyncAction == CalendarSyncAction.create) {
      await _datasource.deleteTask(task.id);
      return;
    }

    final deletedTask = await _syncDelegate.markPendingSync(
      task.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      ),
      action: CalendarSyncAction.delete,
      status: CalendarSyncStatus.pending,
    );

    try {
      if (!await _safeIsAuthorized()) {
        throw const CalendarSyncWarningException(
          'La tarea se elimino localmente. La sincronizacion con Google Calendar queda pendiente.',
        );
      }

      await _syncDelegate.deleteRemoteTask(deletedTask);
      await _datasource.deleteTask(task.id);
    } on CalendarSyncWarningException {
      rethrow;
    } catch (error) {
      await _syncDelegate.markPendingSync(
        deletedTask,
        action: CalendarSyncAction.delete,
        status: CalendarSyncStatus.failed,
        errorMessage: error.toString(),
      );
      throw const CalendarSyncWarningException(
        'La tarea se elimino localmente, pero no se pudo sincronizar con Google Calendar.',
      );
    }
  }

  @override
  Future<void> undoDeleteTask(Task task) async {
    final restoredTask = task.copyWith(
      isDeleted: false,
      pendingCalendarSyncAction: null,
      calendarSyncStatus: CalendarSyncStatus.synced,
      lastCalendarSyncError: null,
      updatedAt: DateTime.now(),
    );
    await _datasource.updateTask(TaskModel.fromEntity(restoredTask));
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
  Future<void> syncPendingTasks() async {
    final pendingTasks = await _datasource.getPendingSyncTasks();
    if (pendingTasks.isEmpty) {
      return;
    }

    final isAuthorized = await _safeIsAuthorized();
    for (final model in pendingTasks) {
      final task = model.toEntity();

      if (task.isDeleted) {
        await _syncDelegate.syncPendingDelete(task, isAuthorized);
        continue;
      }

      final action = task.pendingCalendarSyncAction;
      if (action == null) {
        continue;
      }

      if (!isAuthorized) {
        if (task.calendarSyncStatus == CalendarSyncStatus.failed) {
          await _syncDelegate.markPendingSync(
            task,
            action: action,
            status: CalendarSyncStatus.pending,
          );
        }
        continue;
      }

      try {
        await _syncDelegate.performCalendarUpsert(task, action);
      } catch (error) {
        await _syncDelegate.markPendingSync(
          task,
          action: action,
          status: CalendarSyncStatus.failed,
          errorMessage: error.toString(),
        );
      }
    }
  }

  Future<bool> _safeIsAuthorized() async {
    try {
      return await _calendarRepository.isAuthorized();
    } catch (_) {
      return false;
    }
  }

  List<Task> _toEntities(List<TaskModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
