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
    // Only check auth if we're not already in a state that indicates we're signed in
    if (state is! CalendarLoaded && state is! CalendarLoading) {
      emit(CalendarLoading());
      final isAuthorized = await _calendarRepository.isAuthorized();
      if (!isAuthorized) {
        emit(CalendarNeedsSignIn());
        return;
      }
    } else {
      // Don't emit generic loading to avoid showing the spinner again if we have events
      // instead, maybe show a small sync indicator later, but for now we keep the UI stable.
    }

    try {
      final events = await _calendarRepository.getEvents(
        event.start,
        event.end,
      );
      emit(CalendarLoaded(events: events, start: event.start, end: event.end));
    } catch (e) {
      if (e is CalendarAuthRequiredException) {
        emit(CalendarNeedsSignIn());
      } else {
        emit(CalendarError(e.toString()));
      }
    }
  }

  Future<void> _onGoogleSignIn(
    CalendarGoogleSignInRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final linked = await _calendarRepository.signIn();
      if (!linked) {
        emit(CalendarNeedsSignIn());
        return;
      }
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
