import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/presentation/providers/shared_preferences_provider.dart';
import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';

final FutureProvider<ThemeLocalDataSource> themeLocalDataSourceProvider =
    FutureProvider<ThemeLocalDataSource>((Ref ref) async {
      final SharedPreferences sharedPreferences = await ref
          .watch(sharedPreferencesServiceProvider)
          .initialize();

      return ThemeLocalDataSource(sharedPreferences);
    });

final Provider<ThemeRepository> themeRepositoryProvider = Provider<ThemeRepository>((Ref ref) {
  final ThemeLocalDataSource localDataSource = ref.watch(themeLocalDataSourceProvider).requireValue;

  return ThemeRepositoryImpl(localDataSource);
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final ThemeLocalDataSource localDataSource = ref
        .watch(themeLocalDataSourceProvider)
        .requireValue;

    return localDataSource.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final ThemeRepository repository = ref.read(themeRepositoryProvider);
    final bool isDarkMode = state == ThemeMode.dark;
    final bool newIsDarkMode = !isDarkMode;

    state = newIsDarkMode ? ThemeMode.dark : ThemeMode.light;
    await repository.setIsDarkMode(newIsDarkMode);
  }
}

final NotifierProvider<ThemeNotifier, ThemeMode> themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
