import 'package:app/core/error/exceptions.dart';
import 'package:app/data/services/task_calendar_sync_service.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('notice queue behavior', () {
    test('back-to-back task mutations do NOT overwrite earlier notices', () async {
      final task1 = Task(
        id: 'task-1',
        title: 'Task One',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );
      final task2 = Task(
        id: 'task-2',
        title: 'Task Two',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 19, minute: 0),
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );
      final repository = FakeTaskRepository(
        tasks: [task1, task2],
        createTaskError: const CalendarSyncWarningException(
          'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
        ),
      );
      final bloc = TaskBloc(repository);

      final states = <TaskState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(TaskCreated(task1));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(TaskCreated(task2));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states[0], isA<TaskLoaded>());
      expect(
        (states[0] as TaskLoaded).noticeMessage,
        'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
      );
      expect(states[1], isA<TaskLoading>());
      expect(states[2], isA<TaskLoaded>());
      expect((states[2] as TaskLoaded).noticeMessage, isNull);
      expect(states[3], isA<TaskLoaded>());
      expect(
        (states[3] as TaskLoaded).noticeMessage,
        'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
      );
      expect(states[4], isA<TaskLoading>());
      expect(states[5], isA<TaskLoaded>());
      expect((states[5] as TaskLoaded).noticeMessage, isNull);

      await subscription.cancel();
      await bloc.close();
    });

    test(
      'delete failures show failure-style message (not success-style)',
      () async {
        final task = Task(
          id: 'task-1',
          title: 'Task to delete',
          dueDate: DateTime(2026, 3, 30),
          dueTime: const TimeOfDay(hour: 18, minute: 0),
          createdAt: DateTime(2026, 3, 28, 10),
          updatedAt: DateTime(2026, 3, 28, 10),
          calendarEventId: 'event-123',
        );
        final repository = FakeTaskRepository(
          tasks: [task],
          deleteTaskError: const CalendarSyncWarningException(
            'No se pudo sincronizar con Google Calendar.',
          ),
        );
        final bloc = TaskBloc(repository);

        final states = <TaskState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(TaskDeleted(task));
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(states[0], isA<TaskLoaded>());
        final loadedState = states[0] as TaskLoaded;
        expect(loadedState.noticeMessage, isNotNull);
        expect(loadedState.noticeMessage, contains('No se pudo sincronizar'));

        await subscription.cancel();
        await bloc.close();
      },
    );

    test('reconcile warnings are surfaced once and then cleared', () async {
      final task = Task(
        id: 'task-1',
        title: 'Task One',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );
      final repository = FakeTaskRepository(tasks: [task]);
      final bloc = TaskBloc(repository);

      final states = <TaskState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(
        const TaskSyncWarningQueued(
          'La sesion comenzo, pero 1 tarea(s) no se pudieron sincronizar.',
        ),
      );
      bloc.add(TasksLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TaskLoaded>());
      final firstLoaded = states[1] as TaskLoaded;
      expect(firstLoaded.noticeMessage, isNotNull);

      bloc.add(TasksLoadRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states[2], isA<TaskLoading>());
      expect(states[3], isA<TaskLoaded>());
      final secondLoaded = states[3] as TaskLoaded;
      expect(secondLoaded.noticeMessage, isNull);

      await subscription.cancel();
      await bloc.close();
    });
  });

  test(
    'TaskCreated keeps the task and exposes a notice when calendar sync fails',
    () async {
      final task = Task(
        id: 'task-1',
        title: 'Repasar algebra',
        dueDate: DateTime(2026, 3, 30),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        createdAt: DateTime(2026, 3, 28, 10),
        updatedAt: DateTime(2026, 3, 28, 10),
      );
      final repository = FakeTaskRepository(
        tasks: [task],
        createTaskError: const CalendarSyncWarningException(
          'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
        ),
      );
      final bloc = TaskBloc(repository);

      final states = <TaskState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(TaskCreated(task));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states[0], isA<TaskLoaded>());
      expect(
        (states[0] as TaskLoaded).noticeMessage,
        'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
      );

      await subscription.cancel();
      await bloc.close();
    },
  );
}

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    required this.tasks,
    this.createTaskError,
    this.deleteTaskError,
    this.reconcileResult,
  });

  final List<Task> tasks;
  final Exception? createTaskError;
  final Exception? deleteTaskError;
  final ReconciliationResult? reconcileResult;

  @override
  Future<Task> createTask(Task task) async {
    if (createTaskError != null) {
      throw createTaskError!;
    }
    return task;
  }

  @override
  Future<void> deleteTask(Task task) async {
    if (deleteTaskError != null) {
      throw deleteTaskError!;
    }
  }

  @override
  Future<List<Task>> getTasks() async => tasks;

  @override
  Future<List<Task>> getTasksByCourse(String courseId) async => tasks;

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async => tasks;

  @override
  Future<void> syncPendingTasks() async {}

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {}

  @override
  Future<void> undoDeleteTask(Task task) async {}

  @override
  Future<Task> updateTask(Task task) async => task;

  @override
  Future<ReconciliationResult> reconcileUnsyncedTasks() async {
    return reconcileResult ??
        const ReconciliationResult(syncedTasks: [], failedTasks: []);
  }
}
