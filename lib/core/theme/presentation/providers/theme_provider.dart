import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/presentation/providers/shared_preferences_provider.dart';
import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/theme_usecases.dart';
import '../theme/theme_service.dart';

part 'theme_provider.g.dart';

@riverpod
ThemeService themeService(Ref ref) => ThemeService();

@riverpod
ThemeLocalDataSource? _themeLocalDataSource(Ref ref) {
  final SharedPreferences? prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  return prefs != null ? ThemeLocalDataSource(prefs) : null;
}

@riverpod
ThemeRepository? _themeRepository(Ref ref) {
  final ThemeLocalDataSource? localDataSource = ref.watch(_themeLocalDataSourceProvider);
  return localDataSource != null ? ThemeRepositoryImpl(localDataSource) : null;
}

@riverpod
FetchThemeModeUseCase? fetchThemeModeUseCase(Ref ref) {
  final ThemeRepository? repository = ref.watch(_themeRepositoryProvider);
  return repository != null ? FetchThemeModeUseCase(repository) : null;
}

@riverpod
SetThemeModeUseCase? setThemeModeUseCase(Ref ref) {
  final ThemeRepository? repository = ref.watch(_themeRepositoryProvider);
  return repository != null ? SetThemeModeUseCase(repository) : null;
}

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final ThemeLocalDataSource? localDataSource = ref.watch(_themeLocalDataSourceProvider);

    if (localDataSource == null) {
      return ThemeMode.light;
    }

    return localDataSource.fetchIsDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final SetThemeModeUseCase? setThemeModeUseCase = ref.read(setThemeModeUseCaseProvider);
    final bool newIsDark;

    if (setThemeModeUseCase == null) {
      return;
    }

    newIsDark = state != ThemeMode.dark;
    state = newIsDark ? ThemeMode.dark : ThemeMode.light;

    await setThemeModeUseCase(isDarkMode: newIsDark);
  }
}

final NotifierProvider<ThemeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

@riverpod
ThemeData activeThemeData(Ref ref) {
  final ThemeMode mode = ref.watch(themeModeProvider);
  final ThemeService service = ref.watch(themeServiceProvider);

  return mode == ThemeMode.dark ? service.darkTheme : service.lightTheme;
}
