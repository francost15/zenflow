import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:app/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:app/presentation/blocs/calendar/calendar_event.dart';
import 'package:app/presentation/blocs/calendar/calendar_state.dart';

class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({
    required this.isAuthorizedResult,
    this.getEventsResult = const [],
    this.shouldThrowOnGetEvents = false,
    this.shouldThrowAuthRequiredOnGetEvents = false,
  });

  final bool isAuthorizedResult;
  final List<Event> getEventsResult;
  final bool shouldThrowOnGetEvents;
  final bool shouldThrowAuthRequiredOnGetEvents;
  int signInCallCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isAuthorized() async => isAuthorizedResult;

  @override
  Future<bool> signIn() async {
    signInCallCount++;
    return isAuthorizedResult;
  }

  @override
  Future<List<Event>> getEvents(DateTime start, DateTime end) async {
    if (shouldThrowAuthRequiredOnGetEvents) {
      throw CalendarAuthRequiredException();
    }
    if (shouldThrowOnGetEvents) {
      throw Exception('generic error');
    }
    return getEventsResult;
  }

  @override
  Future<Event> createEvent(Event event) async => event;

  @override
  Future<Event> updateEvent(Event event) async => event;

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  void clearAuthorization() {}
}

void main() {
  group('CalendarBloc', () {
    test('connect canceled/denied → CalendarNeedsSignIn', () async {
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: false,
      );
      final bloc = CalendarBloc(calendarRepository);

      final states = <CalendarState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(
        CalendarLoadRequested(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states, contains(isA<CalendarNeedsSignIn>()));

      await subscription.cancel();
      await bloc.close();
    });

    test(
      'token/auth loss during fetch → CalendarNeedsSignIn (not CalendarLoaded([]))',
      () async {
        final calendarRepository = FakeCalendarRepository(
          isAuthorizedResult: true,
          shouldThrowAuthRequiredOnGetEvents: true,
        );
        final bloc = CalendarBloc(calendarRepository);

        final states = <CalendarState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(
          CalendarLoadRequested(
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 1, 31),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(states.last, isA<CalendarNeedsSignIn>());
        expect(states.last, isNot(isA<CalendarLoaded>()));

        await subscription.cancel();
        await bloc.close();
      },
    );

    test('reconnect after auth success → loaded events', () async {
      final events = [Event()..summary = 'Test Event'];
      final calendarRepository = FakeCalendarRepository(
        isAuthorizedResult: true,
        getEventsResult: events,
      );
      final bloc = CalendarBloc(calendarRepository);

      final states = <CalendarState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(
        CalendarLoadRequested(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states.last, isA<CalendarLoaded>());
      expect((states.last as CalendarLoaded).events, equals(events));

      await subscription.cancel();
      await bloc.close();
    });
  });
}
