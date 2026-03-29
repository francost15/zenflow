part of 'task_repository_impl_test.dart';

void registerTaskRepositoryDeleteSyncTests() {
  test('deleteTask removes the linked Google Calendar event', () async {
    final taskDatasource = FakeTaskDatasource();
    final calendarRepository = FakeCalendarRepository(isAuthorizedResult: true);
    final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

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
    'deleteTask hides the task locally when Calendar deletion fails',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
        throwOnDelete: true,
      );
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

      final task = Task(
        id: 'task-1',
        title: 'Entregar avance',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 9, minute: 30),
        calendarEventId: 'calendar-event-1',
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );

      await expectLater(
        repository.deleteTask(task),
        throwsA(isA<CalendarSyncWarningException>()),
      );

      expect(taskDatasource.deletedTaskId, isNull);
      expect(taskDatasource.updatedTask?.isDeleted, isTrue);
      expect(taskDatasource.updatedTask?.pendingCalendarSyncAction, 'delete');
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
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

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
    'updateTask marks the task as pending when Calendar is not connected',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: false,
      );
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

      final task = Task(
        id: 'task-1',
        title: 'Repasar algebra',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 12),
      );

      await expectLater(
        repository.updateTask(task),
        throwsA(isA<CalendarSyncWarningException>()),
      );

      expect(taskDatasource.updatedTask?.pendingCalendarSyncAction, 'create');
      expect(taskDatasource.updatedTask?.calendarSyncStatus, 'pending');
    },
  );

  test(
    'syncPendingTasks completes a pending delete once Calendar reconnects',
    () async {
      final task = TaskModel(
        id: 'task-1',
        title: 'Entregar avance',
        dueDate: DateTime(2026, 3, 30),
        dueTime: '09:30',
        priority: 'medium',
        status: 'pending',
        subtasks: const [],
        calendarEventId: 'calendar-event-1',
        isDeleted: true,
        pendingCalendarSyncAction: 'delete',
        calendarSyncStatus: 'pending',
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );
      final taskDatasource = FakeTaskDatasource(initialTasks: [task]);
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

      await repository.syncPendingTasks();

      expect(calendarRepository.deletedEventId, 'calendar-event-1');
      expect(taskDatasource.deletedTaskId, 'task-1');
    },
  );
}
