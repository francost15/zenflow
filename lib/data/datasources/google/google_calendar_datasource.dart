import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarDatasource {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  calendar.CalendarApi? _calendarApi;

  /// Initializes GoogleSignIn. Must be called before other methods.
  Future<void> initialize() async {
    await _googleSignIn.initialize();
  }

  /// Checks if user is already signed in via google_sign_in
  Future<bool> isAuthorized() async {
    // In 7.x API, we check by attempting lightweight auth
    final account = await _googleSignIn.attemptLightweightAuthentication();
    return account != null;
  }

  /// Signs in and obtains calendar API access
  Future<void> signIn() async {
    final account = await _googleSignIn.authenticate();
    if (account != null) {
      // Get authorization headers for the calendar scope
      final authHeaders = await account.authorizationClient
          .authorizationHeaders(_scopes);
      if (authHeaders != null) {
        _calendarApi = calendar.CalendarApi(_AuthenticatedClient(authHeaders));
      }
    }
  }

  Future<List<calendar.Event>> getEvents(DateTime start, DateTime end) async {
    if (_calendarApi == null) {
      await signIn();
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
