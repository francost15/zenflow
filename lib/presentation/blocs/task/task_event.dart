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
  final Task task;

  const TaskDeleted(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskStatusToggled extends TaskEvent {
  final Task task;
  final bool completed;

  const TaskStatusToggled({required this.task, required this.completed});

  @override
  List<Object?> get props => [task, completed];
}

class TaskSyncWarningQueued extends TaskEvent {
  final String message;

  const TaskSyncWarningQueued(this.message);

  @override
  List<Object?> get props => [message];
}
