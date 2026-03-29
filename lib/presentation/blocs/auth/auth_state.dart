import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool calendarLinked;
  final String? noticeMessage;

  const AuthAuthenticated(
    this.user, {
    this.calendarLinked = false,
    this.noticeMessage,
  });

  @override
  List<Object?> get props => [user.uid, calendarLinked, noticeMessage];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
