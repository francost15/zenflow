part of 'task_repository_impl_test.dart';

class FakeTaskDatasource implements TaskDatasource {
  FakeTaskDatasource({
    this.throwOnUpdate = false,
    List<TaskModel> initialTasks = const [],
  }) : _storage = {for (final task in initialTasks) task.id: task};

  final bool throwOnUpdate;
  final Map<String, TaskModel> _storage;
  TaskModel? updatedTask;
  String? deletedTaskId;

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final created = TaskModel(
      id: 'task-1',
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      priority: task.priority,
      status: task.status,
      courseId: task.courseId,
      subtasks: task.subtasks,
      calendarEventId: task.calendarEventId,
      isDeleted: task.isDeleted,
      pendingCalendarSyncAction: task.pendingCalendarSyncAction,
      calendarSyncStatus: task.calendarSyncStatus,
      lastCalendarSyncError: task.lastCalendarSyncError,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
    _storage[created.id] = created;
    return created;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    deletedTaskId = taskId;
    _storage.remove(taskId);
  }

  @override
  Future<List<TaskModel>> getPendingSyncTasks() async {
    return _storage.values
        .where(
          (task) =>
              task.pendingCalendarSyncAction != null ||
              task.calendarSyncStatus != 'synced' ||
              task.isDeleted,
        )
        .toList();
  }

  @override
  Future<List<TaskModel>> getTasks({bool includeDeleted = false}) async {
    final tasks = _storage.values.toList();
    return includeDeleted
        ? tasks
        : tasks.where((task) => !task.isDeleted).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByCourse(
    String courseId, {
    bool includeDeleted = false,
  }) async {
    final tasks = _storage.values
        .where((task) => task.courseId == courseId)
        .toList();
    return includeDeleted
        ? tasks
        : tasks.where((task) => !task.isDeleted).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByDate(
    DateTime date, {
    bool includeDeleted = false,
  }) async {
    final tasks = _storage.values.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
    return includeDeleted
        ? tasks
        : tasks.where((task) => !task.isDeleted).toList();
  }

  @override
  Future<List<TaskModel>> getTasksWithoutCalendarEvent() async {
    return _storage.values
        .where((task) => task.calendarEventId == null)
        .toList();
  }

  @override
  Future<void> toggleTaskStatus(String taskId, bool completed) async {}

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    updatedTask = task;
    _storage[task.id] = task;
    return task;
  }
}

class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({
    required this.isAuthorizedResult,
    this.throwOnDelete = false,
    this.deleteErrorStatus,
    this.updateErrorStatus,
  });

  final bool isAuthorizedResult;
  final bool throwOnDelete;
  final int? deleteErrorStatus;
  final int? updateErrorStatus;
  int createEventCallCount = 0;
  int updateEventCallCount = 0;
  Event? lastCreatedEvent;
  Event? lastUpdatedEvent;
  String? deletedEventId;

  @override
  Future<Event> createEvent(Event event) async {
    createEventCallCount += 1;
    lastCreatedEvent = event;
    return event..id = 'calendar-event-1';
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    if (deleteErrorStatus != null) {
      throw DetailedApiRequestError(deleteErrorStatus, 'delete failed');
    }
    if (throwOnDelete) {
      throw Exception('delete failed');
    }
    deletedEventId = eventId;
  }

  @override
  Future<List<Event>> getEvents(DateTime start, DateTime end) async => const [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isAuthorized() async => isAuthorizedResult;

  @override
  Future<bool> signIn() async => true;

  @override
  Future<Event> updateEvent(Event event) async {
    updateEventCallCount += 1;
    lastUpdatedEvent = event;
    if (updateErrorStatus != null) {
      throw DetailedApiRequestError(updateErrorStatus!, 'update failed');
    }
    return event;
  }

  @override
  void clearAuthorization() {}
}
