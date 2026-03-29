import 'package:googleapis/calendar/v3.dart';

class CalendarAuthRequiredException implements Exception {
  @override
  String toString() => 'CalendarAuthRequiredException';
}

abstract class CalendarRepository {
  Future<void> initialize();
  Future<List<Event>> getEvents(DateTime start, DateTime end);
  Future<Event> createEvent(Event event);
  Future<Event> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Future<bool> isAuthorized();
  Future<bool> signIn();
  void clearAuthorization();
}
