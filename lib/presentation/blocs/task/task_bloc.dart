import 'package:app/core/error/exceptions.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/task/task_event.dart';
import 'package:app/presentation/blocs/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  DateTime? _selectedDate;
  final List<String> _pendingNotices = [];
  List<Task> _lastLoadedTasks = [];

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
      _sortTasks(tasks);
      _lastLoadedTasks = tasks;
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
      _sortTasks(tasks);
      _lastLoadedTasks = tasks;
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
      emit(TaskLoaded(tasks: _lastLoadedTasks, noticeMessage: e.message));
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

  void _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      // 1. Pending/InProgress before Completed
      if (a.status == TaskStatus.completed && b.status != TaskStatus.completed) return 1;
      if (a.status != TaskStatus.completed && b.status == TaskStatus.completed) return -1;

      // 2. Sort by time ascending
      int timeCompare = 0;
      if (a.dueTime != null && b.dueTime != null) {
        timeCompare = (a.dueTime!.hour * 60 + a.dueTime!.minute)
            .compareTo(b.dueTime!.hour * 60 + b.dueTime!.minute);
      } else if (a.dueTime != null) {
        timeCompare = -1;
      } else if (b.dueTime != null) {
        timeCompare = 1;
      }
      if (timeCompare != 0) return timeCompare;

      // 3. Sort by priority descending (High > Medium > Low)
      return b.priority.index.compareTo(a.priority.index);
    });
  }
}
