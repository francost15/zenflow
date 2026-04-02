part of 'auth_bloc_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user});

  final User? user;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => user;

  @override
  Future<void> signInWithEmail(String email, String password) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmail(String email, String password) async {}
}

class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({
    required this.isAuthorizedResult,
    this.shouldFailOnSignIn = false,
  });

  final bool isAuthorizedResult;
  final bool shouldFailOnSignIn;
  int clearAuthorizationCallCount = 0;
  int signInCallCount = 0;

  @override
  Future<Event> createEvent(Event event) async => event;

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Future<List<Event>> getEvents(DateTime start, DateTime end) async => const [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isAuthorized() async => isAuthorizedResult;

  @override
  Future<bool> signIn() async {
    signInCallCount += 1;
    if (shouldFailOnSignIn) {
      throw Exception('calendar failed');
    }
    return true;
  }

  @override
  Future<Event> updateEvent(Event event) async => event;

  @override
  void clearAuthorization() {
    clearAuthorizationCallCount += 1;
  }
}

class FakeUser implements User {
  @override
  String get uid => 'user-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.shouldFailOnReconcile = false});

  final bool shouldFailOnReconcile;
  bool reconcileUnsyncedTasksCalled = false;

  @override
  Future<Task> createTask(Task task) async => task;

  @override
  Future<void> deleteTask(Task task) async {}

  @override
  Future<TaskSyncSnapshot> getTaskSyncSnapshot() async {
    return const TaskSyncSnapshot();
  }

  @override
  Future<Task?> getTaskByCalendarEventId(String calendarEventId) async => null;

  @override
  Future<List<Task>> getTasks() async => [];

  @override
  Future<List<Task>> getTasksByCourse(String courseId) async => [];

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async => [];

  @override
  Future<ReconciliationResult> reconcileUnsyncedTasks() async {
    reconcileUnsyncedTasksCalled = true;
    if (shouldFailOnReconcile) {
      throw Exception('reconciliation failed');
    }
    return const ReconciliationResult(syncedTasks: [], failedTasks: []);
  }

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {}

  @override
  Future<Task> updateTask(Task task) async => task;
}
