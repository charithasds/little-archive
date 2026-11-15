import '../repositories/theme_repository.dart';

class FetchThemeModeUseCase {
  const FetchThemeModeUseCase(this.repository);
  final ThemeRepository repository;

  Future<bool> call() => repository.fetchIsDarkMode();
}

class SetThemeModeUseCase {
  const SetThemeModeUseCase(this.repository);

  final ThemeRepository repository;

  Future<void> call({required bool isDarkMode}) async {
    await repository.setIsDarkMode(isDarkMode);
  }
}
