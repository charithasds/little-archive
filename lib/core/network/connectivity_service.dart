import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service class for checking network connectivity status.
/// This is used to prevent CUD operations when the device is offline.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  /// Checks if the device currently has an active network connection.
  /// Returns true if connected (WiFi, mobile, ethernet, vpn, bluetooth),
  /// false otherwise.
  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasConnection(results);
    } catch (_) {
      // If we can't check, assume offline for safety
      return false;
    }
  }

  /// Stream that emits connectivity changes.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  /// Helper to determine if any of the results indicate a connection.
  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}
