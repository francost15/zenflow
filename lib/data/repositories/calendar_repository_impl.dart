import 'package:app/data/datasources/google/google_calendar_datasource.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:googleapis/calendar/v3.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final GoogleCalendarDatasource _datasource;

  CalendarRepositoryImpl(this._datasource);

  @override
  Future<void> initialize() => _datasource.initialize();

  @override
  Future<bool> isAuthorized() => _datasource.isAuthorized();

  @override
  Future<bool> signIn() async => (await _datasource.signIn()) != null;

  @override
  Future<List<Event>> getEvents(DateTime start, DateTime end) =>
      _datasource.getEvents(start, end);

  @override
  Future<Event> createEvent(Event event) => _datasource.createEvent(event);

  @override
  Future<Event> updateEvent(Event event) => _datasource.updateEvent(event);

  @override
  Future<void> deleteEvent(String eventId) => _datasource.deleteEvent(eventId);

  @override
  void clearAuthorization() => _datasource.clearAuthorization();
}
