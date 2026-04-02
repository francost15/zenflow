import 'package:app/core/error/exceptions.dart';
import 'package:app/data/datasources/firestore/task_datasource.dart';
import 'package:app/data/models/task_model.dart';
import 'package:app/data/repositories/task_repository_sync.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

class TaskCalendarSyncService {
  TaskCalendarSyncService(this._datasource, this._calendarRepository)
    : _syncDelegate = TaskRepositorySyncDelegate(
        _datasource,
        _calendarRepository,
      );

  final TaskDatasource _datasource;
  final CalendarRepository _calendarRepository;
  final TaskRepositorySyncDelegate _syncDelegate;

  Future<Task> createAndLink(Task task) async {
    final createdTask = (await _datasource.createTask(
      TaskModel.fromEntity(
        _touchTask(
          task,
          action: CalendarSyncAction.create,
          status: CalendarSyncStatus.pending,
        ),
      ),
    )).toEntity();

    return _syncDelegate.syncTaskImmediately(
      createdTask,
      preferredAction: CalendarSyncAction.create,
      unauthorizedMessage:
          'La tarea se guardo, pero Google Calendar no esta conectado.',
      failureMessage:
          'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
    );
  }

  Future<Task> updateAndSync(Task task) async {
    final syncAction = _syncDelegate.effectiveUpsertAction(task);
    final locallyUpdatedTask = await _persistLocally(
      task,
      action: syncAction,
      status: CalendarSyncStatus.pending,
    );

    return _syncDelegate.syncTaskImmediately(
      locallyUpdatedTask,
      preferredAction: syncAction,
      unauthorizedMessage:
          'La tarea se actualizo, pero Google Calendar no esta conectado.',
      failureMessage:
          'La tarea se actualizo, pero no se pudo sincronizar con Google Calendar.',
    );
  }

  Future<void> deleteAndUnlink(Task task) async {
    if (task.calendarEventId == null) {
      await _datasource.deleteTask(task.id);
      return;
    }

    final softDeletedTask = await _persistLocally(
      task,
      action: CalendarSyncAction.delete,
      status: CalendarSyncStatus.pending,
      isDeleted: true,
    );

    try {
      final isAuthorized = await _calendarRepository.isAuthorized();
      if (!isAuthorized) {
        throw const CalendarSyncWarningException(
          'No se pudo eliminar la tarea porque Google Calendar no esta conectado.',
        );
      }

      await _syncDelegate.deleteRemoteTask(softDeletedTask);
      await _datasource.deleteTask(task.id);
    } on CalendarSyncWarningException catch (error) {
      await _syncDelegate.markPendingSync(
        softDeletedTask.copyWith(isDeleted: true),
        action: CalendarSyncAction.delete,
        status: CalendarSyncStatus.pending,
        errorMessage: error.message,
      );
      rethrow;
    } catch (_) {
      const failureMessage =
          'No se pudo eliminar la tarea porque no se pudo sincronizar con Google Calendar.';
      await _syncDelegate.markPendingSync(
        softDeletedTask.copyWith(isDeleted: true),
        action: CalendarSyncAction.delete,
        status: CalendarSyncStatus.failed,
        errorMessage: failureMessage,
      );
      throw const CalendarSyncWarningException(failureMessage);
    }
  }

  Future<ReconciliationResult> reconcileUnsyncedTasks(List<Task> tasks) async {
    final syncedTasks = <Task>[];
    final failedTasks = <Task>[];
    final isAuthorized = await _calendarRepository.isAuthorized();

    for (final task in tasks) {
      try {
        final reconciledTask = await _reconcileTask(task, isAuthorized);
        if (reconciledTask != null) {
          syncedTasks.add(reconciledTask);
        }
      } catch (_) {
        failedTasks.add(task);
      }
    }

    return ReconciliationResult(
      syncedTasks: syncedTasks,
      failedTasks: failedTasks,
    );
  }

  Future<Task?> _reconcileTask(Task task, bool isAuthorized) async {
    if (task.isDeleted ||
        task.pendingCalendarSyncAction == CalendarSyncAction.delete) {
      await _syncDelegate.syncPendingDelete(task, isAuthorized);
      return null;
    }

    final action = _syncDelegate.effectiveUpsertAction(
      task,
      fallback: task.pendingCalendarSyncAction ?? CalendarSyncAction.update,
    );

    if (!isAuthorized) {
      await _syncDelegate.markPendingSync(
        task,
        action: action,
        status: CalendarSyncStatus.pending,
        errorMessage: 'Google Calendar no esta conectado.',
      );
      throw const CalendarSyncWarningException(
        'Google Calendar no esta conectado.',
      );
    }

    return _syncDelegate.performCalendarUpsert(task, action);
  }

  Future<Task> _persistLocally(
    Task task, {
    required CalendarSyncAction action,
    required CalendarSyncStatus status,
    bool isDeleted = false,
  }) async {
    final persistedTask = await _datasource.updateTask(
      TaskModel.fromEntity(
        _touchTask(
          task,
          action: action,
          status: status,
          isDeleted: isDeleted,
        ),
      ),
    );
    return persistedTask.toEntity();
  }

  Task _touchTask(
    Task task, {
    required CalendarSyncAction action,
    required CalendarSyncStatus status,
    bool isDeleted = false,
  }) {
    return task.copyWith(
      isDeleted: isDeleted,
      pendingCalendarSyncAction: action,
      calendarSyncStatus: status,
      lastCalendarSyncError: null,
      updatedAt: DateTime.now(),
    );
  }
}
