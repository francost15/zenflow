import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/calendar_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final CalendarRepository _calendarRepository;

  AuthBloc(this._authRepository, this._calendarRepository)
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
