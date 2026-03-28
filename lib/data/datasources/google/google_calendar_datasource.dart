import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarDatasource {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  calendar.CalendarApi? _calendarApi;

  /// Stream of authentication events from Google Sign-In.
  /// On web, sign-in happens via GoogleSignInButton widget.
  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  /// Initializes GoogleSignIn. Must be called once at app startup.
  Future<void> initialize() async {
    await _googleSignIn.initialize();
  }

  /// Checks if user is already signed in via google_sign_in.
  Future<bool> isAuthorized() async {
    // In 7.x API, we try lightweight auth - returns null if user interaction needed
    final result = await _googleSignIn.attemptLightweightAuthentication();
    return result != null;
  }

  /// Initiates sign-in flow.
  ///
  /// On web: This returns null immediately because sign-in requires user
  /// interaction with the GoogleSignInButton widget. The actual sign-in
  /// result comes through the [authenticationEvents] stream.
  ///
  /// On mobile: This triggers the native sign-in flow.
  Future<GoogleSignInAccount?> signIn() async {
    if (kIsWeb) {
      // On web, sign-in requires button click. Return null and wait for
      // authenticationEvents stream to emit the sign-in event.
      return null;
    }
    // On mobile, use native authenticate
    final account = await _googleSignIn.authenticate();
    if (account != null) {
      await _setupCalendarApi(account);
    }
    return account;
  }

  /// Handles the sign-in event from the authentication stream.
  /// Called by UI when it receives a sign-in event from GoogleSignInButton.
  Future<void> handleWebSignIn(GoogleSignInAccount account) async {
    await _setupCalendarApi(account);
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
      // Try to get current user via lightweight auth
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        await _setupCalendarApi(account);
      }
    }

    if (_calendarApi == null) {
      throw Exception('Google Calendar not authorized. Please sign in first.');
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
