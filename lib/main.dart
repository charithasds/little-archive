import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/presentation/providers/theme_provider.dart';
import 'core/utils/snackbar_utils.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    // Check for duplicate app error and ignore it, otherwise rethrow
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Check connectivity and disable Firestore if offline to prevent startup logs
  final List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
  final bool isOffline =
      connectivityResults.isEmpty ||
      connectivityResults.every((ConnectivityResult r) => r == ConnectivityResult.none);

  if (isOffline) {
    await FirebaseFirestore.instance.disableNetwork();
  }

  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // ignore: always_specify_types
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
      child: const LittleArchiveApp(),
    ),
  );
}

class LittleArchiveApp extends ConsumerWidget {
  const LittleArchiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Little Archive',
      scaffoldMessengerKey: SnackBarUtils.messengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        return ConnectivityWrapper(child: child!);
      },
    );
  }
}
