import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../routes/router_service.dart';
import 'initialization_provider.dart';

part 'router_service_provider.g.dart';

@riverpod
RouterService routerService(Ref ref) => RouterService();

@riverpod
GoRouter goRouter(Ref ref) {
  final AsyncValue<void> init = ref.watch(initializationProvider);
  final RouterService routerService = ref.read(routerServiceProvider);
  final AsyncValue<UserEntity?> auth = ref.watch(authStateProvider);

  if (!init.hasValue && init.isLoading) {
    return routerService.createRouter(init, const AsyncValue<UserEntity?>.loading());
  }

  return routerService.createRouter(init, auth);
}
