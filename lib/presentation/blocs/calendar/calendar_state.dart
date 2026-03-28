import 'package:equatable/equatable.dart';
import 'package:googleapis/calendar/v3.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final List<Event> events;
  final DateTime start;
  final DateTime end;

  const CalendarLoaded({
    required this.events,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [events, start, end];
}

class CalendarNeedsSignIn extends CalendarState {}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
