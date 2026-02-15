import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/connectivity_service.dart';

final Provider<ConnectivityService> connectivityServiceProvider = Provider<ConnectivityService>(
  (Ref ref) => ConnectivityService(),
);

final StreamProvider<bool> connectivityStreamProvider = StreamProvider<bool>((Ref ref) {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);

  return service.onConnectivityChanged;
});
