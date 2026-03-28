import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository _calendarRepository;

  CalendarBloc(this._calendarRepository) : super(CalendarInitial()) {
    on<CalendarLoadRequested>(_onLoadRequested);
    on<CalendarGoogleSignInRequested>(_onGoogleSignIn);
    on<CalendarRefreshRequested>(_onRefresh);
  }

  Future<void> _onLoadRequested(
    CalendarLoadRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final isAuthorized = await _calendarRepository.isAuthorized();
      if (!isAuthorized) {
        emit(CalendarNeedsSignIn());
        return;
      }

      final events = await _calendarRepository.getEvents(
        event.start,
        event.end,
      );
      emit(CalendarLoaded(events: events, start: event.start, end: event.end));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onGoogleSignIn(
    CalendarGoogleSignInRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      await _calendarRepository.signIn();
      // After successful sign-in, reload events for current month
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      final events = await _calendarRepository.getEvents(start, end);
      emit(CalendarLoaded(events: events, start: start, end: end));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    CalendarRefreshRequested event,
    Emitter<CalendarState> emit,
  ) async {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      add(
        CalendarLoadRequested(start: currentState.start, end: currentState.end),
      );
    }
  }
}
