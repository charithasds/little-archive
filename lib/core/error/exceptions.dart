/// Custom exception thrown when a network operation is attempted
/// but the device has no internet connection.
class NoConnectionException implements Exception {
  final String message;

  const NoConnectionException([
    this.message =
        'No internet connection. Please check your network and try again.',
  ]);

  @override
  String toString() => message;
}

/// Custom exception for server-related errors.
class ServerException implements Exception {
  final String message;

  const ServerException([
    this.message = 'Server error occurred. Please try again later.',
  ]);

  @override
  String toString() => message;
}

/// Custom exception for cache-related errors.
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache error occurred.']);

  @override
  String toString() => message;
}
