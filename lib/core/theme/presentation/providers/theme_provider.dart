import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';

// Provider for SharedPreferences - This will be overridden in main.dart
final Provider<SharedPreferences> sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError();
});

// Provider for ThemeLocalDataSource
final Provider<ThemeLocalDataSource> themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((Ref ref) {
  final SharedPreferences sharedPrefs = ref.watch(sharedPreferencesProvider);
  return ThemeLocalDataSource(sharedPrefs);
});

// Provider for ThemeRepository
final Provider<ThemeRepository> themeRepositoryProvider = Provider<ThemeRepository>((Ref ref) {
  final ThemeLocalDataSource localDataSource = ref.watch(themeLocalDataSourceProvider);
  return ThemeRepositoryImpl(localDataSource);
});

// Notifier for ThemeMode
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final ThemeLocalDataSource localDataSource = ref.watch(themeLocalDataSourceProvider);
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

final NotifierProvider<ThemeNotifier, ThemeMode> themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
