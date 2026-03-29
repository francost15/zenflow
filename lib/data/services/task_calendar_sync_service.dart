import 'package:googleapis/calendar/v3.dart' as calendar;

import '../../core/error/exceptions.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/firestore/task_datasource.dart';
import '../models/task_model.dart';

class ReconciliationResult {
  final List<Task> syncedTasks;
  final List<Task> failedTasks;

  const ReconciliationResult({
    required this.syncedTasks,
    required this.failedTasks,
  });
}

class TaskCalendarSyncService {
  final TaskDatasource _datasource;
  final CalendarRepository _calendarRepository;

  TaskCalendarSyncService(this._datasource, this._calendarRepository);

  Future<Task> createAndLink(Task task) async {
    final model = TaskModel.fromEntity(task);
    final created = await _datasource.createTask(model);
    final createdTask = created.toEntity();
    String? createdEventId;

    try {
      final isAuthorized = await _calendarRepository.isAuthorized();
      if (!isAuthorized) {
        throw const CalendarSyncWarningException(
          'La tarea se guardo, pero Google Calendar no esta conectado.',
        );
      }

      final createdEvent = await _calendarRepository.createEvent(
        _toCalendarEvent(createdTask),
      );
      createdEventId = createdEvent.id;
      final syncedTask = createdTask.copyWith(calendarEventId: createdEvent.id);
      final syncedModel = await _datasource.updateTask(
        TaskModel.fromEntity(syncedTask),
      );
      return syncedModel.toEntity();
    } on CalendarSyncWarningException {
      rethrow;
    } catch (_) {
      if (createdEventId != null) {
        try {
          await _calendarRepository.deleteEvent(createdEventId);
        } catch (_) {}
      }
      throw const CalendarSyncWarningException(
        'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
      );
    }
  }

  Future<Task> updateAndSync(Task task) async {
    final model = TaskModel.fromEntity(task);
    final updated = await _datasource.updateTask(model);
    final updatedTask = updated.toEntity();

    try {
      final isAuthorized = await _calendarRepository.isAuthorized();
      if (!isAuthorized) {
        if (updatedTask.calendarEventId == null) {
          return updatedTask;
        }
        throw const CalendarSyncWarningException(
          'La tarea se actualizo, pero Google Calendar no esta conectado.',
        );
      }

      if (updatedTask.calendarEventId == null) {
        return await _backfillCalendarEvent(updatedTask);
      }

      final event = _toCalendarEvent(updatedTask)
        ..id = updatedTask.calendarEventId;
      await _calendarRepository.updateEvent(event);
      return updatedTask;
    } on CalendarSyncWarningException {
      rethrow;
    } on calendar.DetailedApiRequestError catch (error) {
      if (error.status == 404) {
        return await _recreateMissingEvent(updatedTask);
      }
      throw const CalendarSyncWarningException(
        'La tarea se actualizo, pero no se pudo sincronizar con Google Calendar.',
      );
    } catch (_) {
      throw const CalendarSyncWarningException(
        'La tarea se actualizo, pero no se pudo sincronizar con Google Calendar.',
      );
    }
  }

  Future<Task> _backfillCalendarEvent(Task task) async {
    final createdEvent = await _calendarRepository.createEvent(
      _toCalendarEvent(task),
    );
    try {
      final syncedTask = task.copyWith(calendarEventId: createdEvent.id);
      final syncedModel = await _datasource.updateTask(
        TaskModel.fromEntity(syncedTask),
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

  Future<Task> _recreateMissingEvent(Task task) async {
    final createdEvent = await _calendarRepository.createEvent(
      _toCalendarEvent(task),
    );
    final syncedTask = task.copyWith(calendarEventId: createdEvent.id);
    final syncedModel = await _datasource.updateTask(
      TaskModel.fromEntity(syncedTask),
    );
    return syncedModel.toEntity();
  }

  Future<void> deleteAndUnlink(Task task) async {
    if (task.calendarEventId == null) {
      await _datasource.deleteTask(task.id);
      return;
    }

    try {
      final isAuthorized = await _calendarRepository.isAuthorized();
      if (!isAuthorized) {
        throw const CalendarSyncWarningException(
          'No se pudo eliminar la tarea porque Google Calendar no esta conectado.',
        );
      }

      await _calendarRepository.deleteEvent(task.calendarEventId!);
      await _datasource.deleteTask(task.id);
    } on calendar.DetailedApiRequestError catch (error) {
      if (error.status == 404) {
        await _datasource.deleteTask(task.id);
        return;
      }
      throw const CalendarSyncWarningException(
        'No se pudo eliminar la tarea porque no se pudo sincronizar con Google Calendar.',
      );
    } on CalendarSyncWarningException {
      rethrow;
    } catch (_) {
      throw const CalendarSyncWarningException(
        'No se pudo eliminar la tarea porque no se pudo sincronizar con Google Calendar.',
      );
    }
  }

  Future<ReconciliationResult> reconcileUnsyncedTasks(List<Task> tasks) async {
    final syncedTasks = <Task>[];
    final failedTasks = <Task>[];

    for (final task in tasks) {
      if (task.calendarEventId != null) {
        continue;
      }

      try {
        final syncedTask = await _backfillCalendarEvent(task);
        syncedTasks.add(syncedTask);
      } catch (_) {
        failedTasks.add(task);
      }
    }

    return ReconciliationResult(
      syncedTasks: syncedTasks,
      failedTasks: failedTasks,
    );
  }

  calendar.Event _toCalendarEvent(Task task) {
    final event = calendar.Event()
      ..summary = _calendarSummaryFor(task)
      ..description = task.description;

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

  String _calendarSummaryFor(Task task) {
    final baseTitle = task.title.startsWith('✓ ')
        ? task.title.substring(2)
        : task.title;
    return task.status == TaskStatus.completed ? '✓ $baseTitle' : baseTitle;
  }
}
