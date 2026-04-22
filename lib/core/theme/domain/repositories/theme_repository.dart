abstract class ThemeRepository {
  Future<bool> fetchIsDarkMode();

  Future<void> setIsDarkMode(bool isDarkMode);
}
