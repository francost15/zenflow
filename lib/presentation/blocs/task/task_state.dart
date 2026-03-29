import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final DateTime? selectedDate;
  final String? noticeMessage;

  const TaskLoaded({
    required this.tasks,
    this.selectedDate,
    this.noticeMessage,
  });

  @override
  List<Object?> get props => [tasks, selectedDate, noticeMessage];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
