import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleCalendarDatasource {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  calendar.CalendarApi? _calendarApi;

  Future<void> initialize() async {
    final auth = await _googleSignIn.signInSilently();
    if (auth != null) {
      _calendarApi = calendar.CalendarApi(auth);
    }
  }

  Future<bool> isAuthorized() async {
    return _googleSignIn.isSignedIn();
  }

  Future<void> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account != null) {
      _calendarApi = calendar.CalendarApi(account);
    }
  }

  Future<List<calendar.Event>> getEvents(DateTime start, DateTime end) async {
    if (_calendarApi == null) {
      await initialize();
    }

    final request = calendar.EventsList(
      'primary',
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    final events = await _calendarApi!.events.list(request);
    return events.items ?? [];
  }

  Future<calendar.Event> createEvent(calendar.Event event) async {
    return await _calendarApi!.events.insert(event, 'primary');
  }

  Future<calendar.Event> updateEvent(calendar.Event event) async {
    return await _calendarApi!.events.update(event, 'primary', event.id!);
  }

  Future<void> deleteEvent(String eventId) async {
    await _calendarApi!.events.delete('primary', eventId);
  }
}
