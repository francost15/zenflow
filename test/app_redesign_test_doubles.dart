part of 'app_redesign_test.dart';

class FakeHabitRepository implements HabitRepository {
  FakeHabitRepository({required List<Habit> habits}) : _habits = habits;

  final List<Habit> _habits;

  @override
  Future<Habit> checkIn(String habitId) async {
    return _habits.firstWhere((habit) => habit.id == habitId);
  }

  @override
  Future<Habit> createHabit(String name, String? icon) async {
    final habit = Habit(
      id: 'habit-${_habits.length + 1}',
      name: name,
      icon: icon,
    );
    _habits.add(habit);
    return habit;
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((habit) => habit.id == habitId);
  }

  @override
  Future<List<Habit>> getHabits() async => List<Habit>.from(_habits);
}

class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository({required List<Course> courses}) : _courses = courses;

  final List<Course> _courses;

  @override
  Future<Course> createCourse(Course course) async {
    _courses.add(course);
    return course;
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((course) => course.id == courseId);
  }

  @override
  Future<List<Course>> getCourses() async => List<Course>.from(_courses);

  @override
  Future<void> updateProgress(String courseId, double progress) async {}

  @override
  Future<Course> updateCourse(Course course) async {
    final index = _courses.indexWhere((item) => item.id == course.id);
    _courses[index] = course;
    return course;
  }
}

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({required List<Task> tasks}) : _tasks = tasks;

  final List<Task> _tasks;

  @override
  Future<Task> createTask(Task task) async {
    _tasks.add(task);
    return task;
  }

  @override
  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((item) => item.id == task.id);
  }

  @override
  Future<List<Task>> getTasks() async =>
      List<Task>.from(_tasks.where((task) => !task.isDeleted));

  @override
  Future<List<Task>> getTasksByCourse(String courseId) async => List<Task>.from(
    _tasks.where((task) => task.courseId == courseId && !task.isDeleted),
  );

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async => List<Task>.from(
    _tasks.where(
      (task) =>
          !task.isDeleted &&
          task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day,
    ),
  );

  @override
  Future<void> syncPendingTasks() async {}

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      return;
    }
    _tasks[index] = task.copyWith(
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> undoDeleteTask(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      _tasks.add(task.copyWith(isDeleted: false));
      return;
    }
    _tasks[index] = _tasks[index].copyWith(isDeleted: false);
  }

  @override
  Future<Task> updateTask(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    _tasks[index] = task;
    return task;
  }
}

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
  @override
  void clearAuthorization() {}

  @override
  Future<Event> createEvent(Event event) async => event;

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Future<List<Event>> getEvents(DateTime start, DateTime end) async => const [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isAuthorized() async => false;

  @override
  Future<bool> signIn() async => false;

  @override
  Future<Event> updateEvent(Event event) async => event;
}

class FakeUser implements User {
  const FakeUser({
    required this.uidValue,
    this.displayNameValue,
    this.emailValue,
    this.photoUrlValue,
  });

  final String uidValue;
  final String? displayNameValue;
  final String? emailValue;
  final String? photoUrlValue;

  @override
  String? get displayName => displayNameValue;

  @override
  String? get email => emailValue;

  @override
  String? get photoURL => photoUrlValue;

  @override
  String get uid => uidValue;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
