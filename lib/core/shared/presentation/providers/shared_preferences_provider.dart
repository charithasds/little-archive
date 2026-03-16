import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single, shared [SharedPreferences] instance for the entire app.
/// Initialized once during app startup via [initializationProvider].
final FutureProvider<SharedPreferences> sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((Ref ref) async => SharedPreferences.getInstance());
