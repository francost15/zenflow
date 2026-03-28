import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TaskEvent {}

class TasksByDateRequested extends TaskEvent {
  final DateTime date;

  const TasksByDateRequested(this.date);

  @override
  List<Object?> get props => [date];
}

class TaskCreated extends TaskEvent {
  final Task task;

  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskEvent {
  final Task task;

  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskDeleted extends TaskEvent {
  final String taskId;

  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskStatusToggled extends TaskEvent {
  final String taskId;
  final bool completed;

  const TaskStatusToggled({required this.taskId, required this.completed});

  @override
  List<Object?> get props => [taskId, completed];
}
