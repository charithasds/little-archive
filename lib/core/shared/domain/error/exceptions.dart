/// Exception thrown when there is no internet connection.
class NoConnectionException implements Exception {
  const NoConnectionException([
    this.message = 'No internet connection. Please check your network and try again.',
  ]);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when a server-side error occurs.
class ServerException implements Exception {
  const ServerException([this.message = 'Server error occurred. Please try again later.']);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when a local cache operation fails.
class CacheException implements Exception {
  const CacheException([this.message = 'Cache error occurred.']);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when a user tries to perform a protected action without being logged in.
class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'You must be logged in to perform this operation.']);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when a user lacks the necessary permissions for an action.
class PermissionException implements Exception {
  const PermissionException([this.message = 'You do not have permission to perform this action.']);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when a component is accessed before the application state is initialized.
class InitializationException implements Exception {
  const InitializationException([this.message = 'The application has not been fully initialized.']);
  final String message;

  @override
  String toString() => message;
}
