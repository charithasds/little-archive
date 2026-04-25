import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/shared/data/services/connectivity_service.dart';
import 'core/shared/presentation/providers/firestore_network_provider.dart';
import 'core/shared/presentation/routes/router_service.dart';
import 'core/shared/presentation/utils/snack_bars.dart';
import 'core/theme/presentation/providers/theme_provider.dart';
import 'core/theme/presentation/theme/theme_service.dart';

class LittleArchiveApp extends ConsumerStatefulWidget {
  const LittleArchiveApp({super.key});

  @override
  ConsumerState<LittleArchiveApp> createState() => _LittleArchiveAppState();
}

class _LittleArchiveAppState extends ConsumerState<LittleArchiveApp> with WidgetsBindingObserver {
  bool? _previousConnectivity;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      return;
    }

    final FirestoreNetwork notifier = ref.read(firestoreNetworkProvider.notifier);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      notifier.handleLifecyclePaused();
    } else if (state == AppLifecycleState.resumed) {
      notifier.handleLifecycleResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter goRouter = ref.watch(goRouterProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final ThemeService themeService = ref.watch(themeServiceProvider);

    ref.watch(firestoreNetworkProvider);

    ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (
      AsyncValue<bool>? previous,
      AsyncValue<bool> next,
    ) {
      next.whenData((bool isConnected) {
        if (_previousConnectivity != null && _previousConnectivity != isConnected) {
          if (isConnected) {
            SnackBars.showSuccess('You are back online.');
          } else {
            SnackBars.showWarning('You are offline. Some features may be unavailable.');
          }
        }

        _previousConnectivity = isConnected;
      });
    });

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
