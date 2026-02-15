import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/firestore_provider.dart';
import '../providers/router_provider.dart';
import '../widgets/snackbar_utils.dart';

class InitializationAppPage extends ConsumerStatefulWidget {
  const InitializationAppPage({super.key});

  @override
  ConsumerState<InitializationAppPage> createState() => _InitializationAppPageState();
}

class _InitializationAppPageState extends ConsumerState<InitializationAppPage>
    with WidgetsBindingObserver {
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

    final FirestoreNetworkNotifier notifier = ref.read(firestoreNetworkProvider.notifier);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      notifier.handleLifecyclePaused();
    } else if (state == AppLifecycleState.resumed) {
      notifier.handleLifecycleResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);

    ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (
      AsyncValue<bool>? previous,
      AsyncValue<bool> next,
    ) {
      next.whenData((bool isConnected) {
        if (_previousConnectivity != null && _previousConnectivity != isConnected) {
          if (isConnected) {
            SnackBarUtils.showSuccess(context, 'You are back online.');
          } else {
            SnackBarUtils.showWarning(
              context,
              'You are offline. Some features may be unavailable.',
            );
          }
        }

        _previousConnectivity = isConnected;
      });
    });

    ref.watch(firestoreNetworkProvider);

    return MaterialApp.router(
      title: 'Little Archive',
      scaffoldMessengerKey: SnackBarUtils.messengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
