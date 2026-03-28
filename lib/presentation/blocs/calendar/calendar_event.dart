import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class CalendarLoadRequested extends CalendarEvent {
  final DateTime start;
  final DateTime end;

  const CalendarLoadRequested({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class CalendarGoogleSignInRequested extends CalendarEvent {}

class CalendarRefreshRequested extends CalendarEvent {}
