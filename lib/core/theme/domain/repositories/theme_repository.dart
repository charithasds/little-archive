/// [ThemeRepository] defines the contract for persisting and retrieving theme preferences.
abstract class ThemeRepository {
  /// Retrieves whether dark mode is currently enabled.
  Future<bool> getIsDarkMode();

  /// Persists the user's preference for dark mode.
  Future<void> setIsDarkMode(bool isDarkMode);
}
