import 'package:flutter/material.dart';

import '../repositories/theme_repository.dart';

/// Use case to retrieve the current [ThemeMode] from persistence.
class GetThemeModeUseCase {
  /// Creates a [GetThemeModeUseCase] with the given [repository].
  const GetThemeModeUseCase(this.repository);
  final ThemeRepository repository;

  /// Retrieves the theme mode from the repository.
  Future<ThemeMode> call() async {
    final bool isDark = await repository.getIsDarkMode();
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Use case to persist the chosen theme mode.
class SetThemeModeUseCase {
  /// Creates a [SetThemeModeUseCase] with the given [repository].
  const SetThemeModeUseCase(this.repository);

  /// The repository for theme preferences.
  final ThemeRepository repository;

  /// Saves the new [isDarkMode] preference to the repository.
  Future<void> call({required bool isDarkMode}) async {
    await repository.setIsDarkMode(isDarkMode);
  }
}
