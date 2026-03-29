import 'package:googleapis/calendar/v3.dart' as calendar;

import '../../core/error/exceptions.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firestore/task_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _datasource;
  final CalendarRepository _calendarRepository;

  TaskRepositoryImpl(this._datasource, this._calendarRepository);

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

  @override
  Future<Task> updateTask(Task task) async {
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
        final createdEvent = await _calendarRepository.createEvent(
          _toCalendarEvent(updatedTask),
        );
        try {
          final syncedTask = updatedTask.copyWith(
            calendarEventId: createdEvent.id,
          );
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

      final event = _toCalendarEvent(updatedTask)
        ..id = updatedTask.calendarEventId;
      await _calendarRepository.updateEvent(event);
      return updatedTask;
    } on CalendarSyncWarningException {
      rethrow;
    } catch (_) {
      throw const CalendarSyncWarningException(
        'La tarea se actualizo, pero no se pudo sincronizar con Google Calendar.',
      );
    }
  }

  @override
  Future<void> deleteTask(Task task) async {
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

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {
    final updatedTask = task.copyWith(
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      updatedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
  }
}
