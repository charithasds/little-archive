import 'package:flutter/material.dart';

import '../repositories/theme_repository.dart';

class FetchThemeModeUseCase {
  const FetchThemeModeUseCase(this.repository);
  final ThemeRepository repository;

  Future<ThemeMode> call() async {
    final bool isDark = await repository.fetchIsDarkMode();
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class SetThemeModeUseCase {
  const SetThemeModeUseCase(this.repository);

  final ThemeRepository repository;

  Future<void> call({required bool isDarkMode}) async {
    await repository.setIsDarkMode(isDarkMode);
  }
}
