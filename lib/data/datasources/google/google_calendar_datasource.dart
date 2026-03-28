import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarDatasource {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  calendar.CalendarApi? _calendarApi;

  Future<void> initialize() async {
    final auth = await _googleSignIn.signInSilently();
    if (auth != null) {
      final authHeaders = await auth.authHeaders;
      _calendarApi = calendar.CalendarApi(_AuthenticatedClient(authHeaders));
    }
  }

  Future<bool> isAuthorized() async {
    return _googleSignIn.isSignedIn();
  }

  Future<void> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account != null) {
      final authHeaders = await account.authHeaders;
      _calendarApi = calendar.CalendarApi(_AuthenticatedClient(authHeaders));
    }
  }

  Future<List<calendar.Event>> getEvents(DateTime start, DateTime end) async {
    if (_calendarApi == null) {
      await initialize();
    }

    final events = await _calendarApi!.events.list(
      'primary',
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );
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

class _AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;

  _AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(_headers);
    return request.send();
  }
}
