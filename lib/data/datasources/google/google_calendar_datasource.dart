import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Google Calendar datasource.
///
/// IMPORTANT: On mobile, Google Calendar API requires additional OAuth configuration:
/// - A serverClientId with "Google Calendar API" scope authorized
/// - This is DIFFERENT from Firebase Auth's OAuth client
///
/// For now, mobile returns empty events until proper OAuth is configured.
/// On web, it shows a "not available" message (see CalendarScreen).
class GoogleCalendarDatasource {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  calendar.CalendarApi? _calendarApi;

  /// Stream of authentication events from Google Sign-In.
  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  /// Initializes GoogleSignIn with serverClientId for Calendar API.
  /// On mobile, serverClientId MUST be provided for Calendar access.
  Future<void> initialize({String? serverClientId}) async {
    await _googleSignIn.initialize(serverClientId: serverClientId);
  }

  /// Checks if user is already signed in via google_sign_in.
  Future<bool> isAuthorized() async {
    if (!kIsWeb) {
      // On mobile, google_sign_in requires serverClientId for Calendar
      // Without it, we cannot authenticate for Calendar API
      return false;
    }
    final result = await _googleSignIn.attemptLightweightAuthentication();
    return result != null;
  }

  /// Initiates sign-in flow.
  ///
  /// On web: Returns null, sign-in happens via button widget.
  /// On mobile: Requires serverClientId to be set in initialize().
  Future<GoogleSignInAccount?> signIn() async {
    if (kIsWeb) {
      return null;
    }
    try {
      // Request Calendar scope during authentication
      final account = await _googleSignIn.authenticate(scopeHint: _scopes);
      await _setupCalendarApi(account);
      return account;
    } catch (e) {
      // On mobile without proper OAuth config, this will fail
      // Calendar will show empty state
      debugPrint('Calendar sign-in error: $e');
      return null;
    }
  }

  Future<void> _setupCalendarApi(GoogleSignInAccount account) async {
    final authHeaders = await account.authorizationClient.authorizationHeaders(
      _scopes,
    );
    if (authHeaders != null) {
      _calendarApi = calendar.CalendarApi(_AuthenticatedClient(authHeaders));
    }
  }

  Future<List<calendar.Event>> getEvents(DateTime start, DateTime end) async {
    if (_calendarApi == null) {
      if (!kIsWeb) {
        // On mobile, Calendar requires proper OAuth setup
        // Return empty list instead of throwing
        return [];
      }
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        await _setupCalendarApi(account);
      }
    }

    if (_calendarApi == null) {
      // Return empty instead of throwing - more user-friendly
      return [];
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
