import 'package:googleapis/calendar/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarDatasource {
  static const _scopes = [CalendarApi.calendarScope];

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  CalendarApi? _calendarApi;

  Future<void> initialize() async {
    final auth = await _googleSignIn.signInSilently();
    if (auth != null) {
      _calendarApi = CalendarApi(_getAuthenticatedClient(auth));
    }
  }

  http.Client _getAuthenticatedClient(GoogleSignInAuthentication auth) {
    final client = http.Client();
    // In production, you'd use auth.accessToken directly
    // This is simplified
    return client;
  }

  Future<bool> isAuthorized() async {
    return _googleSignIn.isSignedIn();
  }

  Future<void> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account != null) {
      final auth = await account.authentication;
      _calendarApi = CalendarApi(_getAuthenticatedClient(auth));
    }
  }

  Future<List<Event>> getEvents(DateTime start, DateTime end) async {
    if (_calendarApi == null) {
      await initialize();
    }

    final calendarId = 'primary';
    final request = EventsList(
      calendarId: calendarId,
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    final events = await _calendarApi!.events.list(request);
    return events.items ?? [];
  }

  Future<Event> createEvent(Event event) async {
    return await _calendarApi!.events.insert(event, 'primary');
  }

  Future<Event> updateEvent(Event event) async {
    return await _calendarApi!.events.update(event, 'primary', event.id!);
  }

  Future<void> deleteEvent(String eventId) async {
    await _calendarApi!.events.delete('primary', eventId);
  }
}
