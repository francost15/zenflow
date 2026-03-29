import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  DateTime? _selectedDate;
  final List<String> _pendingNotices = [];

  TaskBloc(this._taskRepository) : super(TaskInitial()) {
    on<TasksLoadRequested>(_onLoadRequested);
    on<TasksByDateRequested>(_onByDateRequested);
    on<TaskCreated>(_onCreated);
    on<TaskUpdated>(_onUpdated);
    on<TaskDeleted>(_onDeleted);
    on<TaskStatusToggled>(_onStatusToggled);
    on<TaskSyncWarningQueued>(_onSyncWarningQueued);
  }

  Future<void> _onLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getTasks();
      emit(
        TaskLoaded(tasks: tasks, noticeMessage: _consumeNextPendingNotice()),
      );
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
      emit(
        TaskLoaded(
          tasks: tasks,
          selectedDate: event.date,
          noticeMessage: _consumeNextPendingNotice(),
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreated(TaskCreated event, Emitter<TaskState> emit) async {
    final success = await _runTaskMutation(
      () => _taskRepository.createTask(event.task),
      emit,
    );
    if (success) {
      _refreshTasks();
    }
  }

  Future<void> _onUpdated(TaskUpdated event, Emitter<TaskState> emit) async {
    final success = await _runTaskMutation(
      () => _taskRepository.updateTask(event.task),
      emit,
    );
    if (success) {
      _refreshTasks();
    }
  }

  Future<void> _onDeleted(TaskDeleted event, Emitter<TaskState> emit) async {
    final success = await _runTaskMutation(
      () => _taskRepository.deleteTask(event.task),
      emit,
    );
    if (success) {
      _refreshTasks();
    }
  }

  Future<void> _onStatusToggled(
    TaskStatusToggled event,
    Emitter<TaskState> emit,
  ) async {
    final success = await _runTaskMutation(
      () => _taskRepository.toggleTaskStatus(event.task, event.completed),
      emit,
    );
    if (success) {
      _refreshTasks();
    }
  }

  void _onSyncWarningQueued(
    TaskSyncWarningQueued event,
    Emitter<TaskState> emit,
  ) {
    _pendingNotices.add(event.message);
  }

  String? _consumeNextPendingNotice() {
    if (_pendingNotices.isEmpty) return null;
    return _pendingNotices.removeAt(0);
  }

  Future<bool> _runTaskMutation(
    Future<dynamic> Function() action,
    Emitter<TaskState> emit,
  ) async {
    try {
      await action();
      return true;
    } on CalendarSyncWarningException catch (e) {
      _pendingNotices.add(e.message);
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      return false;
    }
  }

  void _refreshTasks() {
    if (_selectedDate != null) {
      add(TasksByDateRequested(_selectedDate!));
    } else {
      add(TasksLoadRequested());
    }
  }
}
