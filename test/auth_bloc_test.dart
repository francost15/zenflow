import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart';

import 'package:app/data/services/task_calendar_sync_service.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/auth_repository.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/auth/auth_bloc.dart';
import 'package:app/presentation/blocs/auth/auth_event.dart';
import 'package:app/presentation/blocs/auth/auth_state.dart';

void main() {
  test(
    'AuthCheckRequested restores Calendar link state for persisted sessions',
    () async {
      final authRepository = FakeAuthRepository(user: FakeUser());
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final taskRepository = FakeTaskRepository();
      final bloc = AuthBloc(authRepository, calendarRepository, taskRepository);

      final states = <AuthState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(AuthCheckRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states.single, isA<AuthAuthenticated>());
      expect((states.single as AuthAuthenticated).calendarLinked, isTrue);

      await subscription.cancel();
      await bloc.close();
    },
  );

  test('AuthGoogleSignInRequested links Google Calendar after login', () async {
    final authRepository = FakeAuthRepository(user: FakeUser());
    final calendarRepository = FakeCalendarRepository(isAuthorizedResult: true);
    final taskRepository = FakeTaskRepository();
    final bloc = AuthBloc(authRepository, calendarRepository, taskRepository);

    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(AuthGoogleSignInRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states[0], isA<AuthLoading>());
    expect(states[1], isA<AuthAuthenticated>());
    expect((states[1] as AuthAuthenticated).calendarLinked, isTrue);
    expect(calendarRepository.signInCallCount, 1);

    await subscription.cancel();
    await bloc.close();
  });

  test('AuthSignOutRequested clears cached Calendar authorization', () async {
    final authRepository = FakeAuthRepository(user: FakeUser());
    final calendarRepository = FakeCalendarRepository(isAuthorizedResult: true);
    final taskRepository = FakeTaskRepository();
    final bloc = AuthBloc(authRepository, calendarRepository, taskRepository);

    bloc.add(AuthSignOutRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(calendarRepository.clearAuthorizationCallCount, 1);

    await bloc.close();
  });

  test(
    'AuthGoogleSignInRequested still authenticates when Calendar linking fails',
    () async {
      final authRepository = FakeAuthRepository(user: FakeUser());
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: false,
        shouldFailOnSignIn: true,
      );
      final taskRepository = FakeTaskRepository();
      final bloc = AuthBloc(authRepository, calendarRepository, taskRepository);

      final states = <AuthState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(AuthGoogleSignInRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      final authenticatedState = states[1] as AuthAuthenticated;
      expect(authenticatedState.calendarLinked, isFalse);
      expect(authenticatedState.noticeMessage, isNotNull);

      await subscription.cancel();
      await bloc.close();
    },
  );

  test(
    'AuthGoogleSignInRequested triggers reconciliation for unsynced tasks after successful calendar link',
    () async {
      final authRepository = FakeAuthRepository(user: FakeUser());
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final taskRepository = FakeTaskRepository();
      final bloc = AuthBloc(authRepository, calendarRepository, taskRepository);

      final states = <AuthState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(AuthGoogleSignInRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      expect(taskRepository.reconcileUnsyncedTasksCalled, isTrue);

      await subscription.cancel();
      await bloc.close();
    },
  );

  test(
    'AuthGoogleSignInRequested still succeeds if reconciliation fails; notice is surfaced',
    () async {
      final authRepository = FakeAuthRepository(user: FakeUser());
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
      );
      final taskRepository = FakeTaskRepository(shouldFailOnReconcile: true);
      final bloc = AuthBloc(authRepository, calendarRepository, taskRepository);

      final states = <AuthState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(AuthGoogleSignInRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      final authenticatedState = states[1] as AuthAuthenticated;
      expect(authenticatedState.calendarLinked, isTrue);
      expect(authenticatedState.noticeMessage, isNotNull);

      await subscription.cancel();
      await bloc.close();
    },
  );
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user});

  final User? user;

  @override
  User? get currentUser => user;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

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
  Future<List<Task>> getTasks() async => [];

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async => [];

  @override
  Future<Task> createTask(Task task) async => task;

  @override
  Future<Task> updateTask(Task task) async => task;

  @override
  Future<void> deleteTask(Task task) async {}

  @override
  Future<void> toggleTaskStatus(Task task, bool completed) async {}

  @override
  Future<ReconciliationResult> reconcileUnsyncedTasks() async {
    reconcileUnsyncedTasksCalled = true;
    if (shouldFailOnReconcile) {
      throw Exception('reconciliation failed');
    }
    return const ReconciliationResult(syncedTasks: [], failedTasks: []);
  }
}
