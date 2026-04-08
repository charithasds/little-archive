import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service that monitors and reports the device's network connectivity status.
class ConnectivityService {
  /// Creates a [ConnectivityService]. An optional [connectivity] instance can be provided for testing.
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Checks the current network connectivity status.
  /// Returns `true` if any connection (Wi-Fi, Mobile, etc.) is available, `false` otherwise.
  Future<bool> isConnected() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();

      return results.any((ConnectivityResult result) => result != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  /// A stream that emits a boolean whenever the network connectivity status changes.
  /// Emits `true` if connected, `false` if disconnected.
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged.map(
    (List<ConnectivityResult> results) =>
        results.any((ConnectivityResult result) => result != ConnectivityResult.none),
  );
}
