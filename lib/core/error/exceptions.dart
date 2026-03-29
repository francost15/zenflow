/// Base exception class for the ZenFlow app.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' ($code)' : ''}';
}

/// Exception thrown when user is not authenticated.
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Exception thrown when network operations fail.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Exception thrown when permission is denied.
class PermissionException extends AppException {
  const PermissionException(super.message, [super.code]);
}

/// Exception thrown when a resource already exists.
class AlreadyExistsException extends AppException {
  const AlreadyExistsException(super.message, [super.code]);
}

/// Exception thrown when a resource is not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}

/// Exception thrown when primary work succeeds but Google Calendar sync fails.
class CalendarSyncWarningException extends AppException {
  const CalendarSyncWarningException(super.message, [super.code]);
}
