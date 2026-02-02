import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_service.dart';

/// Provider for the ConnectivityService singleton.
final Provider<ConnectivityService> connectivityServiceProvider = Provider<ConnectivityService>((Ref ref) {
  return ConnectivityService();
});

/// Provider that exposes a stream of connectivity status.
/// true = connected, false = disconnected.
final StreamProvider<bool> connectivityStreamProvider = StreamProvider<bool>((Ref ref) {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Provider for checking current connectivity status.
/// This is useful for one-time checks before CUD operations.
final FutureProvider<bool> isConnectedProvider = FutureProvider<bool>((Ref ref) async {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);
  return service.isConnected();
});
