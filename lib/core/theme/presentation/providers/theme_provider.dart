import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/presentation/providers/shared_preferences_provider.dart';
import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';

/// Returns null while [sharedPreferencesProvider] is still loading —
/// which happens during the initialization splash. Once resolved, returns
/// the real data source backed by SharedPreferences.
final Provider<ThemeLocalDataSource?> themeLocalDataSourceProvider =
    Provider<ThemeLocalDataSource?>((Ref ref) {
      final SharedPreferences? prefs = ref.watch(sharedPreferencesProvider).asData?.value;

      if (prefs == null) {
        return null;
      }

      return ThemeLocalDataSource(prefs);
    });

/// Only accessed after initialization (from [ThemeNotifier.toggleTheme]),
/// so the data source is guaranteed to be non-null by then.
final Provider<ThemeRepository?> themeRepositoryProvider = Provider<ThemeRepository?>((Ref ref) {
  final ThemeLocalDataSource? localDataSource = ref.watch(themeLocalDataSourceProvider);

  if (localDataSource == null) {
    return null;
  }

  return ThemeRepositoryImpl(localDataSource);
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final ThemeLocalDataSource? localDataSource = ref.watch(themeLocalDataSourceProvider);

    // SharedPreferences not yet loaded (shown during initialization splash/error).
    // Defaults to light — the notifier rebuilds automatically once resolved.
    if (localDataSource == null) {
      return ThemeMode.light;
    }

    return localDataSource.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final ThemeRepository? repository = ref.read(themeRepositoryProvider);

    // Guard: not null in practice, but safe to skip if somehow called during loading.
    if (repository == null) {
      return;
    }

    final bool newIsDark = state != ThemeMode.dark;
    state = newIsDark ? ThemeMode.dark : ThemeMode.light;
    await repository.setIsDarkMode(newIsDark);
  }
}

final NotifierProvider<ThemeNotifier, ThemeMode> themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
