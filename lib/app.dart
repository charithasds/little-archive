import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/shared/presentation/providers/connectivity_provider.dart';
import 'core/shared/presentation/providers/firestore_network_provider.dart';
import 'core/shared/presentation/providers/router_service_provider.dart';
import 'core/shared/presentation/utils/snack_bars.dart';
import 'core/theme/presentation/providers/theme_provider.dart';
import 'core/theme/presentation/theme/theme_service.dart';

/// The root widget of the Little Archive application.
///
/// It initializes the application's theme, routing, and monitors global states
/// like network connectivity and Firebase synchronization.
class LittleArchiveApp extends ConsumerStatefulWidget {
  /// Creates the [LittleArchiveApp].
  const LittleArchiveApp({super.key});

  @override
  ConsumerState<LittleArchiveApp> createState() => _LittleArchiveAppState();
}

class _LittleArchiveAppState extends ConsumerState<LittleArchiveApp> with WidgetsBindingObserver {
  /// Stores the previous value of connectivity to detect changes.
  bool? _previousConnectivity;

  @override
  void initState() {
    super.initState();
    // Register this class as an observer to track app lifecycle changes.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister the lifecycle observer.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      return;
    }

    final FirestoreNetworkNotifier notifier = ref.read(firestoreNetworkProvider.notifier);

    // Coordinate Firestore synchronization states based on app lifecycle.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      notifier.handleLifecyclePaused();
    } else if (state == AppLifecycleState.resumed) {
      notifier.handleLifecycleResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch relevant providers for theme and navigation.
    final GoRouter goRouter = ref.watch(goRouterProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final ThemeService themeService = ref.watch(themeServiceProvider);

    // Activate firestore network monitoring.
    ref.watch(firestoreNetworkProvider);

    // Monitor connectivity changes to provide user feedback through Snackbars.
    ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (
      AsyncValue<bool>? previous,
      AsyncValue<bool> next,
    ) {
      next.whenData((bool isConnected) {
        if (_previousConnectivity != null && _previousConnectivity != isConnected) {
          if (isConnected) {
            SnackBars.showSuccess(context, 'You are back online.');
          } else {
            SnackBars.showWarning(context, 'You are offline. Some features may be unavailable.');
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
