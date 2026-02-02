/// Custom exception thrown when a network operation is attempted
/// but the device has no internet connection.
class NoConnectionException implements Exception {

  const NoConnectionException([
    this.message =
        'No internet connection. Please check your network and try again.',
  ]);
  final String message;

  @override
  String toString() => message;
}

/// Custom exception for server-related errors.
class ServerException implements Exception {

  const ServerException([
    this.message = 'Server error occurred. Please try again later.',
  ]);
  final String message;

  @override
  String toString() => message;
}

/// Custom exception for cache-related errors.
class CacheException implements Exception {

  const CacheException([this.message = 'Cache error occurred.']);
  final String message;

  @override
  String toString() => message;
}
