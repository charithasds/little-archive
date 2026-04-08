import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/theme_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/theme_usecases.dart';
import '../theme/theme_service.dart';

/// Provider for the [ThemeService] instance.
final Provider<ThemeService> themeServiceProvider = Provider<ThemeService>(
  (Ref ref) => ThemeService(),
);

/// Provider for [GetThemeModeUseCase].
/// Null until the repository is ready.
final Provider<GetThemeModeUseCase?> getThemeModeUseCaseProvider = Provider<GetThemeModeUseCase?>((
  Ref ref,
) {
  final ThemeRepository? repository = ref.watch(themeRepositoryProvider);

  return repository != null ? GetThemeModeUseCase(repository) : null;
});

/// Provider for [SetThemeModeUseCase].
/// Null until the repository is ready.
final Provider<SetThemeModeUseCase?> setThemeModeUseCaseProvider = Provider<SetThemeModeUseCase?>((
  Ref ref,
) {
  final ThemeRepository? repository = ref.watch(themeRepositoryProvider);

  return repository != null ? SetThemeModeUseCase(repository) : null;
});

/// A notifier that manages the application's [ThemeMode].
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final ThemeLocalDataSource? localDataSource = ref.watch(themeLocalDataSourceProvider);

    // Initial build defaults to light if data source isn't ready.
    if (localDataSource == null) {
      return ThemeMode.light;
    }

    // Synchronously reads the last saved value to avoid flicker where possible.
    return localDataSource.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggles between light and dark themes.
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

/// Provider for the [ThemeNotifier].
final NotifierProvider<ThemeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

/// Provider for the currently active [ThemeData].
///
/// Reacts to changes in [themeModeProvider] and returns the corresponding
/// light or dark theme values from [ThemeService].
final Provider<ThemeData> activeThemeDataProvider = Provider<ThemeData>((Ref ref) {
  final ThemeMode mode = ref.watch(themeModeProvider);
  final ThemeService service = ref.watch(themeServiceProvider);

  return mode == ThemeMode.dark ? service.darkTheme : service.lightTheme;
});
