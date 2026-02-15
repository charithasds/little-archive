import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isConnected() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();

      return _hasConnection(results);
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return false;
    }

    return results.any((ConnectivityResult r) => r != ConnectivityResult.none);
  }
}
