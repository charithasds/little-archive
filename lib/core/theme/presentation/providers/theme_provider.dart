import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';

// Provider for SharedPreferences - This will be overridden in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Provider for ThemeLocalDataSource
final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return ThemeLocalDataSource(sharedPrefs);
});

// Provider for ThemeRepository
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final localDataSource = ref.watch(themeLocalDataSourceProvider);
  return ThemeRepositoryImpl(localDataSource);
});

// Notifier for ThemeMode
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final localDataSource = ref.watch(themeLocalDataSourceProvider);
    return localDataSource.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final repository = ref.read(themeRepositoryProvider);
    final isDarkMode = state == ThemeMode.dark;
    final newIsDarkMode = !isDarkMode;

    state = newIsDarkMode ? ThemeMode.dark : ThemeMode.light;
    await repository.setIsDarkMode(newIsDarkMode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
