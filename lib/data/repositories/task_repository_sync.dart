import 'package:app/core/error/exceptions.dart';
import 'package:app/data/datasources/firestore/task_datasource.dart';
import 'package:app/data/models/task_model.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class TaskRepositorySyncDelegate {
  TaskRepositorySyncDelegate(this._datasource, this._calendarRepository);

  final TaskDatasource _datasource;
  final CalendarRepository _calendarRepository;

  Future<Task> syncTaskImmediately(
    Task task, {
    required CalendarSyncAction preferredAction,
    required String unauthorizedMessage,
    required String failureMessage,
  }) async {
    final action = effectiveUpsertAction(task, fallback: preferredAction);

    try {
      final isAuthorized = await _calendarRepository.isAuthorized();
      if (!isAuthorized) {
        await markPendingSync(
          task,
          action: action,
          status: CalendarSyncStatus.pending,
        );
        throw CalendarSyncWarningException(unauthorizedMessage);
      }

      return await performCalendarUpsert(task, action);
    } on CalendarSyncWarningException {
      rethrow;
    } catch (error) {
      await markPendingSync(
        task,
        action: action,
        status: CalendarSyncStatus.failed,
        errorMessage: error.toString(),
      );
      throw CalendarSyncWarningException(failureMessage);
    }
  }

  Future<Task> performCalendarUpsert(
    Task task,
    CalendarSyncAction action,
  ) async {
    if (action == CalendarSyncAction.create || task.calendarEventId == null) {
      final createdEvent = await _calendarRepository.createEvent(
        toCalendarEvent(task),
      );
      final syncedTask = task.copyWith(calendarEventId: createdEvent.id);

      try {
        final syncedModel = await _datasource.updateTask(
          TaskModel.fromEntity(clearSyncMetadata(syncedTask)),
        );
        return syncedModel.toEntity();
      } catch (_) {
        if (createdEvent.id != null) {
          try {
            await _calendarRepository.deleteEvent(createdEvent.id!);
          } catch (_) {}
        }
        rethrow;
      }
    }

    final event = toCalendarEvent(task)..id = task.calendarEventId;
    try {
      await _calendarRepository.updateEvent(event);
    } on calendar.DetailedApiRequestError catch (error) {
      if (error.status == 404) {
        return performCalendarUpsert(
          task.copyWith(calendarEventId: null),
          CalendarSyncAction.create,
        );
      }
      rethrow;
    }

    final syncedModel = await _datasource.updateTask(
      TaskModel.fromEntity(clearSyncMetadata(task)),
    );
    return syncedModel.toEntity();
  }

  Future<void> syncPendingDelete(Task task, bool isAuthorized) async {
    if (task.calendarEventId == null ||
        task.pendingCalendarSyncAction == CalendarSyncAction.create) {
      await _datasource.deleteTask(task.id);
      return;
    }

    if (!isAuthorized) {
      if (task.calendarSyncStatus == CalendarSyncStatus.failed) {
        await markPendingSync(
          task,
          action: CalendarSyncAction.delete,
          status: CalendarSyncStatus.pending,
        );
      }
      return;
    }

    try {
      await deleteRemoteTask(task);
      await _datasource.deleteTask(task.id);
    } catch (error) {
      await markPendingSync(
        task,
        action: CalendarSyncAction.delete,
        status: CalendarSyncStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> deleteRemoteTask(Task task) async {
    if (task.calendarEventId == null) {
      return;
    }

    try {
      await _calendarRepository.deleteEvent(task.calendarEventId!);
    } on calendar.DetailedApiRequestError catch (error) {
      if (error.status != 404) {
        rethrow;
      }
    }
  }

  Future<Task> markPendingSync(
    Task task, {
    required CalendarSyncAction action,
    required CalendarSyncStatus status,
    String? errorMessage,
  }) async {
    final pendingModel = await _datasource.updateTask(
      TaskModel.fromEntity(
        task.copyWith(
          pendingCalendarSyncAction: action,
          calendarSyncStatus: status,
          lastCalendarSyncError: errorMessage,
        ),
      ),
    );
    return pendingModel.toEntity();
  }

  Task clearSyncMetadata(Task task) {
    return task.copyWith(
      pendingCalendarSyncAction: null,
      calendarSyncStatus: CalendarSyncStatus.synced,
      lastCalendarSyncError: null,
    );
  }

  CalendarSyncAction effectiveUpsertAction(
    Task task, {
    CalendarSyncAction fallback = CalendarSyncAction.update,
  }) {
    if (task.pendingCalendarSyncAction == CalendarSyncAction.create ||
        task.calendarEventId == null) {
      return CalendarSyncAction.create;
    }
    return fallback;
  }

  String _calendarColorIdFor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return '11'; // Tomato Red
      case TaskPriority.medium:
        return '5'; // Banana Yellow
      case TaskPriority.low:
        return '8'; // Graphite
    }
  }

  calendar.Event toCalendarEvent(Task task) {
    final event = calendar.Event()
      ..summary = calendarSummaryFor(task)
      ..description = task.description
      ..colorId = _calendarColorIdFor(task.priority);

    if (task.dueTime == null) {
      final startDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      event.start = calendar.EventDateTime(date: startDate);
      event.end = calendar.EventDateTime(
        date: startDate.add(const Duration(days: 1)),
      );
      return event;
    }

    final startDateTime = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
      task.dueTime!.hour,
      task.dueTime!.minute,
    );
    final endDateTime = startDateTime.add(const Duration(hours: 1));

    event.start = calendar.EventDateTime(
      dateTime: startDateTime.toUtc(),
      timeZone: 'UTC',
    );
    event.end = calendar.EventDateTime(
      dateTime: endDateTime.toUtc(),
      timeZone: 'UTC',
    );
    return event;
  }

  String calendarSummaryFor(Task task) {
    final baseTitle = task.title.startsWith('✓ ')
        ? task.title.substring(2)
        : task.title;
    return task.status == TaskStatus.completed ? '✓ $baseTitle' : baseTitle;
  }
}
