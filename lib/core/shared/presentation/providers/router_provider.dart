import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/router_service.dart';

final Provider<RouterService> routerServiceProvider = Provider<RouterService>(
  (Ref ref) => RouterService(),
);

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final RouterService routerService = ref.read(routerServiceProvider);
  final AsyncValue<UserEntity?> authStateAsync = ref.watch(authStateProvider);

  return routerService.createRouter(authStateAsync);
});
