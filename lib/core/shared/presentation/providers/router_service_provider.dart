import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../routes/router_service.dart';
import 'initialization_provider.dart';

/// Provides the [RouterService] which handles route configuration.
final Provider<RouterService> routerServiceProvider = Provider<RouterService>(
  (Ref ref) => RouterService(),
);

/// Exposes the [GoRouter] instance used for application navigation.
/// It automatically regenerates the router based on initialization and auth states.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((Ref ref) {
  final AsyncValue<void> init = ref.watch(initializationProvider);
  final RouterService routerService = ref.read(routerServiceProvider);
  final AsyncValue<UserEntity?> auth = ref.watch(authStateProvider);

  if (!init.hasValue && init.isLoading) {
    return routerService.createRouter(init, const AsyncValue<UserEntity?>.loading());
  }

  return routerService.createRouter(init, auth);
});
