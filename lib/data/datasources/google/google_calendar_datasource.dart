import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../../domain/repositories/calendar_repository.dart';

/// Google Calendar datasource.
///
/// IMPORTANT: On mobile, Google Calendar API requires additional OAuth configuration:
/// - A serverClientId with "Google Calendar API" scope authorized
class GoogleCalendarDatasource {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  calendar.CalendarApi? _calendarApi;
  bool _isAuthorized = false;

  /// Stream of authentication events from Google Sign-In.
  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  /// Initializes GoogleSignIn with serverClientId for Calendar API.
  /// On mobile, serverClientId MUST be provided for Calendar access.
  Future<void> initialize({String? serverClientId}) async {
    await _googleSignIn.initialize(serverClientId: serverClientId);
  }

  /// Checks if user is already authorized for Calendar API.
  /// Actually checks Google Sign-In status (doesn't just return cached state).
  Future<bool> isAuthorized() async {
    // If we already have a valid API client, return true
    if (_calendarApi != null && _isAuthorized) {
      return true;
    }
    // Try lightweight auth to check if user is already signed in
    try {
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        return await _setupCalendarApi(account);
      }
    } catch (e) {
      // Lightweight auth failed, user needs to explicitly sign in
      debugPrint('Calendar lightweight auth check failed: $e');
    }
    return false;
  }

  /// Initiates sign-in flow and sets up Calendar API access.
  ///
  /// On web: Returns null, sign-in happens via button widget.
  /// On mobile: Uses native Google Sign-In with Calendar scope.
  Future<GoogleSignInAccount?> signIn() async {
    if (kIsWeb) {
      return null;
    }
    try {
      final existingAccount = await _googleSignIn
          .attemptLightweightAuthentication(reportAllExceptions: true);
      final account = existingAccount ?? await _googleSignIn.authenticate();
      final isAuthorized = await _setupCalendarApi(
        account,
        promptIfNecessary: true,
      );
      return isAuthorized ? account : null;
    } catch (e) {
      debugPrint('Calendar sign-in error: $e');
      _isAuthorized = false;
      return null;
    }
  }

  Future<bool> _setupCalendarApi(
    GoogleSignInAccount account, {
    bool promptIfNecessary = false,
  }) async {
    final authHeaders = await account.authorizationClient.authorizationHeaders(
      _scopes,
      promptIfNecessary: promptIfNecessary,
    );
    if (authHeaders == null) {
      _calendarApi = null;
      _isAuthorized = false;
      return false;
    }

    _calendarApi = calendar.CalendarApi(_AuthenticatedClient(authHeaders));
    _isAuthorized = true;
    return true;
  }

  Future<List<calendar.Event>> getEvents(DateTime start, DateTime end) async {
    if (_calendarApi == null) {
      throw CalendarAuthRequiredException();
    }

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      return events.items ?? [];
    } catch (e) {
      debugPrint('Error fetching calendar events: $e');
      rethrow;
    }
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

  /// Clears the authorization state.
  void clearAuthorization() {
    _calendarApi = null;
    _isAuthorized = false;
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
