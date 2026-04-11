import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isConnected() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();

      return results.any((ConnectivityResult result) => result != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged.map(
    (List<ConnectivityResult> results) =>
        results.any((ConnectivityResult result) => result != ConnectivityResult.none),
  );
}
