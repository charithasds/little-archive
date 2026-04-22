import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/theme_usecases.dart';
import '../theme/theme_service.dart';

part 'theme_provider.g.dart';

@riverpod
ThemeService themeService(Ref ref) => ThemeService();

final Provider<FetchThemeModeUseCase?> fetchThemeModeUseCaseProvider = Provider<FetchThemeModeUseCase?>((
  Ref ref,
) {
  final ThemeRepository? repository = ref.watch(themeRepositoryProvider);

  return repository != null ? FetchThemeModeUseCase(repository) : null;
});

final Provider<SetThemeModeUseCase?> setThemeModeUseCaseProvider = Provider<SetThemeModeUseCase?>((
  Ref ref,
) {
  final ThemeRepository? repository = ref.watch(themeRepositoryProvider);

  return repository != null ? SetThemeModeUseCase(repository) : null;
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final ThemeLocalDataSource? localDataSource = ref.watch(themeLocalDataSourceProvider);

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
