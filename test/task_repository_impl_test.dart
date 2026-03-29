import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart';

import 'package:app/data/datasources/firestore/task_datasource.dart';
import 'package:app/data/models/task_model.dart';
import 'package:app/data/repositories/task_repository_impl.dart';
import 'package:app/data/services/task_calendar_sync_service.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/calendar_repository.dart';

void main() {
  TaskRepositoryImpl createRepository(
    FakeTaskDatasource taskDatasource,
    FakeCalendarRepository calendarRepository,
  ) {
    final syncService = TaskCalendarSyncService(
      taskDatasource,
      calendarRepository,
    );
    return TaskRepositoryImpl(taskDatasource, syncService);
  }

  test(
    'createTask syncs a Google Calendar event when calendar is authorized',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final repository = createRepository(taskDatasource, calendarRepository);

      final task = Task(
        id: '',
        title: 'Entregar avance',
        description: 'Enviar primer entregable',
        dueDate: DateTime(2026, 3, 30),
        dueTime: TimeOfDay(hour: 9, minute: 30),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );

      final createdTask = await repository.createTask(task);

      expect(calendarRepository.createEventCallCount, 1);
      expect(calendarRepository.lastCreatedEvent?.summary, 'Entregar avance');
      expect(
        calendarRepository.lastCreatedEvent?.description,
        'Enviar primer entregable',
      );
      expect(createdTask.calendarEventId, 'calendar-event-1');
      expect(taskDatasource.updatedTask?.calendarEventId, 'calendar-event-1');
    },
  );

  test('deleteTask removes the linked Google Calendar event', () async {
    final taskDatasource = FakeTaskDatasource();
    final calendarRepository = FakeCalendarRepository(isAuthorizedResult: true);
    final repository = createRepository(taskDatasource, calendarRepository);

    final task = Task(
      id: 'task-1',
      title: 'Entregar avance',
      dueDate: DateTime(2026, 3, 30),
      dueTime: const TimeOfDay(hour: 9, minute: 30),
      calendarEventId: 'calendar-event-1',
      createdAt: DateTime(2026, 3, 28, 10),
      updatedAt: DateTime(2026, 3, 28, 10),
    );

    await repository.deleteTask(task);

    expect(taskDatasource.deletedTaskId, 'task-1');
    expect(calendarRepository.deletedEventId, 'calendar-event-1');
  });

  test(
    'updateTask syncs changes to the linked Google Calendar event',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final repository = createRepository(taskDatasource, calendarRepository);

      final task = Task(
        id: 'task-1',
        title: 'Entregar avance final',
        description: 'Version corregida',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 11, minute: 0),
        calendarEventId: 'calendar-event-1',
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 12),
      );

      await repository.updateTask(task);

      expect(calendarRepository.updateEventCallCount, 1);
      expect(calendarRepository.lastUpdatedEvent?.id, 'calendar-event-1');
      expect(
        calendarRepository.lastUpdatedEvent?.summary,
        'Entregar avance final',
      );
    },
  );

  test('toggleTaskStatus syncs the linked Google Calendar event', () async {
    final taskDatasource = FakeTaskDatasource();
    final calendarRepository = FakeCalendarRepository(isAuthorizedResult: true);
    final repository = createRepository(taskDatasource, calendarRepository);

    final task = Task(
      id: 'task-1',
      title: 'Entregar avance',
      dueDate: DateTime(2026, 3, 30),
      dueTime: const TimeOfDay(hour: 11, minute: 0),
      status: TaskStatus.pending,
      calendarEventId: 'calendar-event-1',
      createdAt: DateTime(2026, 3, 28, 10),
      updatedAt: DateTime(2026, 3, 28, 12),
    );

    await repository.toggleTaskStatus(task, true);

    expect(taskDatasource.updatedTask?.status, 'completed');
    expect(calendarRepository.updateEventCallCount, 1);
    expect(calendarRepository.lastUpdatedEvent?.summary, '✓ Entregar avance');
  });

  test(
    'updateTask backfills a Google Calendar event when the task is unsynced',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final repository = createRepository(taskDatasource, calendarRepository);

      final task = Task(
        id: 'task-1',
        title: 'Repasar algebra',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 12),
      );

      final updatedTask = await repository.updateTask(task);

      expect(calendarRepository.createEventCallCount, 1);
      expect(taskDatasource.updatedTask?.calendarEventId, 'calendar-event-1');
      expect(updatedTask.calendarEventId, 'calendar-event-1');
    },
  );

  test(
    'createTask rolls back the Google event if saving calendarEventId fails',
    () async {
      final taskDatasource = FakeTaskDatasource(throwOnUpdate: true);
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final repository = createRepository(taskDatasource, calendarRepository);

      final task = Task(
        id: '',
        title: 'Entregar avance',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 9, minute: 30),
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );

      await expectLater(repository.createTask(task), throwsA(isA<Exception>()));

      expect(calendarRepository.deletedEventId, 'calendar-event-1');
    },
  );

  test(
    'deleteTask keeps the local task when Calendar deletion fails',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
        throwOnDelete: true,
      );
      final repository = createRepository(taskDatasource, calendarRepository);

      final task = Task(
        id: 'task-1',
        title: 'Entregar avance',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 9, minute: 30),
        calendarEventId: 'calendar-event-1',
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );

      await expectLater(repository.deleteTask(task), throwsA(isA<Exception>()));

      expect(taskDatasource.deletedTaskId, isNull);
    },
  );

  test(
    'deleteTask removes the local task when the calendar event is already gone',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
        deleteErrorStatus: 404,
      );
      final repository = createRepository(taskDatasource, calendarRepository);

      final task = Task(
        id: 'task-1',
        title: 'Entregar avance',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 9, minute: 30),
        calendarEventId: 'calendar-event-1',
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );

      await repository.deleteTask(task);

      expect(taskDatasource.deletedTaskId, 'task-1');
    },
  );

  test(
    'updateTask self-heals by recreating the linked event when it returns 404',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
        updateErrorStatus: 404,
      );
      final repository = createRepository(taskDatasource, calendarRepository);

      final task = Task(
        id: 'task-1',
        title: 'Repasar algebra',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        calendarEventId: 'missing-event-id',
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 12),
      );

      final updatedTask = await repository.updateTask(task);

      expect(calendarRepository.createEventCallCount, 1);
      expect(taskDatasource.updatedTask?.calendarEventId, 'calendar-event-1');
      expect(updatedTask.calendarEventId, 'calendar-event-1');
    },
  );
}

class FakeTaskDatasource implements TaskDatasource {
  FakeTaskDatasource({this.throwOnUpdate = false});

  final bool throwOnUpdate;
  TaskModel? updatedTask;
  String? deletedTaskId;

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    return TaskModel(
      id: 'task-1',
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      priority: task.priority,
      status: task.status,
      courseId: task.courseId,
      subtasks: task.subtasks,
      calendarEventId: task.calendarEventId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  @override
  Future<void> deleteTask(String taskId) async {
    deletedTaskId = taskId;
  }

  @override
  Future<List<TaskModel>> getTasks({bool includeDeleted = false}) async =>
      const [];

  @override
  Future<List<TaskModel>> getTasksByDate(
    DateTime date, {
    bool includeDeleted = false,
  }) async => const [];

  @override
  Future<List<TaskModel>> getTasksByCourse(
    String courseId, {
    bool includeDeleted = false,
  }) async => const [];

  @override
  Future<List<TaskModel>> getPendingSyncTasks() async => const [];

  @override
  Future<void> toggleTaskStatus(String taskId, bool completed) async {}

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    updatedTask = task;
    return task;
  }

  @override
  Future<List<TaskModel>> getTasksWithoutCalendarEvent() async => const [];
}

class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({
    required this.isAuthorizedResult,
    this.throwOnDelete = false,
    this.deleteErrorStatus,
    this.updateErrorStatus,
  });

  final bool isAuthorizedResult;
  final bool throwOnDelete;
  final int? deleteErrorStatus;
  final int? updateErrorStatus;
  int createEventCallCount = 0;
  int updateEventCallCount = 0;
  Event? lastCreatedEvent;
  Event? lastUpdatedEvent;
  String? deletedEventId;

  @override
  Future<Event> createEvent(Event event) async {
    createEventCallCount += 1;
    lastCreatedEvent = event;
    return event..id = 'calendar-event-1';
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    if (deleteErrorStatus != null) {
      throw DetailedApiRequestError(deleteErrorStatus, 'delete failed');
    }
    if (throwOnDelete) {
      throw Exception('delete failed');
    }
    deletedEventId = eventId;
  }

  @override
  Future<List<Event>> getEvents(DateTime start, DateTime end) async => const [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isAuthorized() async => isAuthorizedResult;

  @override
  Future<bool> signIn() async => true;

  @override
  Future<Event> updateEvent(Event event) async {
    if (updateErrorStatus != null) {
      throw DetailedApiRequestError(updateErrorStatus!, 'update failed');
    }
    updateEventCallCount += 1;
    lastUpdatedEvent = event;
    return event;
  }

  @override
  void clearAuthorization() {}
}
