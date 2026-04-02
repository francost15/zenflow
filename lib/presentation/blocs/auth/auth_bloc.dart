import 'package:app/domain/repositories/auth_repository.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/auth/auth_event.dart';
import 'package:app/presentation/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final CalendarRepository _calendarRepository;
  final TaskRepository _taskRepository;

  AuthBloc(this._authRepository, this._calendarRepository, this._taskRepository)
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final calendarLinked = await _calendarRepository.isAuthorized();
      emit(AuthAuthenticated(user, calendarLinked: calendarLinked));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      var calendarLinked = false;
      String? noticeMessage;
      try {
        calendarLinked = await _calendarRepository.signIn();
        if (!calendarLinked) {
          noticeMessage =
              'Sesion iniciada, pero Google Calendar no quedo conectado.';
        }
      } catch (_) {
        noticeMessage =
            'Sesion iniciada, pero Google Calendar no quedo conectado.';
      }

      if (calendarLinked) {
        try {
          final result = await _taskRepository.reconcileUnsyncedTasks();
          if (result.syncedTasks.isNotEmpty) {
            noticeMessage =
                '${result.syncedTasks.length} tarea(s) sincronizada(s) con Google Calendar.';
          } else if (result.failedTasks.isNotEmpty) {
            noticeMessage =
                'La sesion comenzo, pero ${result.failedTasks.length} tarea(s) no se pudieron sincronizar.';
          }
        } catch (_) {
          noticeMessage =
              'Sesion iniciada. La sincronizacion de tareas pendientes fallo.';
        }
      }

      final user = _authRepository.currentUser;
      if (user != null) {
        emit(
          AuthAuthenticated(
            user,
            calendarLinked: calendarLinked,
            noticeMessage: noticeMessage,
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      _calendarRepository.clearAuthorization();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
