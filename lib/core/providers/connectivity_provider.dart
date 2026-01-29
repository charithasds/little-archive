import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_service.dart';

/// Provider for the ConnectivityService singleton.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Provider that exposes a stream of connectivity status.
/// true = connected, false = disconnected.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Provider for checking current connectivity status.
/// This is useful for one-time checks before CUD operations.
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return service.isConnected();
});
