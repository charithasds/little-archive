import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../firebase_options.dart';
import 'shared_preferences_provider.dart';

/// Bootstraps the app by initializing Firebase and SharedPreferences.
///
/// - Firebase must be initialized before any Firebase service (Auth, Firestore)
///   is accessed.
/// - SharedPreferences is awaited here so that theme and other local
///   settings are available synchronously to the rest of the app.
///
/// Connectivity-based Firestore network toggling is handled separately by
/// [FirestoreNetworkNotifier], which reacts to the connectivity stream.
final FutureProvider<void> initializationProvider = FutureProvider<void>((Ref ref) async {
  // 1. Initialize Firebase (idempotent — safe to call multiple times).
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  // 2. Initialize SharedPreferences and cache the instance in the provider.
  //    Other providers (e.g. themeProvider) can now use ref.watch(sharedPreferencesProvider)
  //    without triggering a second initialization.
  await ref.read(sharedPreferencesProvider.future);
});
