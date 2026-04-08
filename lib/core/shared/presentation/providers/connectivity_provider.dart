import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/connectivity_service.dart';

/// Provides the [ConnectivityService] instance used across the application.
final Provider<ConnectivityService> connectivityServiceProvider = Provider<ConnectivityService>(
  (Ref ref) => ConnectivityService(),
);

/// Exposes a stream of the current network connectivity status.
/// Emits `true` when connected and `false` when disconnected.
final StreamProvider<bool> connectivityStreamProvider = StreamProvider<bool>((Ref ref) {
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);

  return connectivityService.onConnectivityChanged;
});
