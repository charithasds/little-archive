class NoConnectionException implements Exception {
  const NoConnectionException([
    this.message = 'No internet connection. Please check your network and try again.',
  ]);
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

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error occurred.']);
  final String message;

  @override
  String toString() => message;
}
