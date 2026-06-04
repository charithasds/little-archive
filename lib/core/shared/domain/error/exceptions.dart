class CacheException implements Exception {
  const CacheException([this.message = 'Cache error occurred.']);
  final String message;

  @override
  String toString() => message;
}

class InitializationException implements Exception {
  const InitializationException([this.message = 'The application has not been fully initialized.']);
  final String message;

  @override
  String toString() => message;
}

class NoConnectionException implements Exception {
  const NoConnectionException([
    this.message = 'No internet connection. Please check your network and try again.',
  ]);
  final String message;

  @override
  String toString() => message;
}

class PermissionException implements Exception {
  const PermissionException([this.message = 'You do not have permission to perform this action.']);
  final String message;

  @override
  String toString() => message;
}

class ServerException implements Exception {
  const ServerException([this.message = 'Server error occurred. Please try again later.']);
  final String message;

  @override
  String toString() => message;
}
