import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  DateTime? _selectedDate;

  TaskBloc(this._taskRepository) : super(TaskInitial()) {
    on<TasksLoadRequested>(_onLoadRequested);
    on<TasksByDateRequested>(_onByDateRequested);
    on<TaskCreated>(_onCreated);
    on<TaskUpdated>(_onUpdated);
    on<TaskDeleted>(_onDeleted);
    on<TaskStatusToggled>(_onStatusToggled);
  }

  Future<void> _onLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getTasks();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onByDateRequested(
    TasksByDateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    _selectedDate = event.date;
    try {
      final tasks = await _taskRepository.getTasksByDate(event.date);
      emit(TaskLoaded(tasks: tasks, selectedDate: event.date));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreated(TaskCreated event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.createTask(event.task);
      if (_selectedDate != null) {
        add(TasksByDateRequested(_selectedDate!));
      } else {
        add(TasksLoadRequested());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdated(TaskUpdated event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task);
      if (_selectedDate != null) {
        add(TasksByDateRequested(_selectedDate!));
      } else {
        add(TasksLoadRequested());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleted(TaskDeleted event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.taskId);
      if (_selectedDate != null) {
        add(TasksByDateRequested(_selectedDate!));
      } else {
        add(TasksLoadRequested());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onStatusToggled(
    TaskStatusToggled event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _taskRepository.toggleTaskStatus(event.taskId, event.completed);
      if (_selectedDate != null) {
        add(TasksByDateRequested(_selectedDate!));
      } else {
        add(TasksLoadRequested());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
