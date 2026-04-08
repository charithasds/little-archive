import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../firebase_options.dart';
import 'shared_preferences_provider.dart';

/// A global provider that handles the initial setup of the application.
/// It ensures that Firebase and SharedPreferences are fully initialized before the app
/// starts performing any dependent operations.
final FutureProvider<void> initializationProvider = FutureProvider<void>((Ref ref) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  await ref.read(sharedPreferencesProvider.future);
});
