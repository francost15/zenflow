import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/error/exceptions.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';

void main() {
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

      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TaskLoaded>());
      expect(
        (states[1] as TaskLoaded).noticeMessage,
        'La tarea se guardo, pero no se pudo sincronizar con Google Calendar.',
      );

      await subscription.cancel();
      await bloc.close();
    },
  );
}

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({required this.tasks, this.createTaskError});

  final List<Task> tasks;
  final Exception? createTaskError;

  @override
  Future<Task> createTask(Task task) async {
    if (createTaskError != null) {
      throw createTaskError!;
    }
    return task;
  }

  @override
  Future<void> deleteTask(Task task) async {}

  @override
  Future<List<Task>> getTasks() async => tasks;

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async => tasks;

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {}

  @override
  Future<Task> updateTask(Task task) async => task;
}
