import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider that exposes the [SharedPreferences] instance for persistent local storage.
final FutureProvider<SharedPreferences> sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((Ref ref) async => SharedPreferences.getInstance());
