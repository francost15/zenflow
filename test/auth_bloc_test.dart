import 'package:app/domain/entities/task.dart';
import 'package:app/domain/entities/task_sync_snapshot.dart';
import 'package:app/domain/repositories/auth_repository.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/auth/auth_bloc.dart';
import 'package:app/presentation/blocs/auth/auth_event.dart';
import 'package:app/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart';

part 'auth_bloc_test_doubles.dart';

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
