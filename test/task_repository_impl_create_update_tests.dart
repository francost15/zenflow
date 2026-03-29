part of 'task_repository_impl_test.dart';

void registerTaskRepositoryCreateUpdateTests() {
  test(
    'createTask syncs a Google Calendar event when calendar is authorized',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

      final task = Task(
        id: '',
        title: 'Entregar avance',
        description: 'Enviar primer entregable',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 9, minute: 30),
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

  test(
    'updateTask syncs changes to the linked Google Calendar event',
    () async {
      final taskDatasource = FakeTaskDatasource();
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

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
    final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

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
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

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
      final repository = TaskRepositoryImpl(taskDatasource, calendarRepository);

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
}
