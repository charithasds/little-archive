import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/shared/presentation/routes/router_service.dart';
import 'core/shared/presentation/utils/snack_bars.dart';
import 'core/theme/presentation/providers/theme_provider.dart';
import 'core/theme/presentation/theme/theme_service.dart';

class LittleArchiveApp extends ConsumerStatefulWidget {
  const LittleArchiveApp({super.key});

  @override
  ConsumerState<LittleArchiveApp> createState() => _LittleArchiveAppState();
}

class _LittleArchiveAppState extends ConsumerState<LittleArchiveApp> {
  @override
  Widget build(BuildContext context) {
    final GoRouter goRouter = ref.watch(goRouterProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final ThemeService themeService = ref.watch(themeServiceProvider);

    return MaterialApp.router(
      title: 'Little Archive',
      scaffoldMessengerKey: SnackBars.messengerKey,
      debugShowCheckedModeBanner: false,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
