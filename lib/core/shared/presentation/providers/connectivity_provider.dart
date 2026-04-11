import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/connectivity_service.dart';

part 'connectivity_provider.g.dart';

@riverpod
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

@riverpod
Stream<bool> connectivityStream(Ref ref) {
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);

  return connectivityService.onConnectivityChanged;
}
