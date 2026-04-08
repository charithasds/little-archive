import 'package:shared_preferences/shared_preferences.dart';

/// [ThemeLocalDataSource] handles direct interaction with local storage for theme settings.
class ThemeLocalDataSource {
  /// Creates a [ThemeLocalDataSource] with the required [_sharedPreferences].
  ThemeLocalDataSource(this._sharedPreferences);

  /// The underlying storage instance.
  final SharedPreferences _sharedPreferences;

  static const String _themeKey = 'is_dark_mode';

  /// Synchronously gets the dark mode preference from local storage.
  bool getIsDarkMode() => _sharedPreferences.getBool(_themeKey) ?? false;

  /// Asynchronously saves the dark mode preference to local storage.
  Future<void> setIsDarkMode(bool isDarkMode) async {
    await _sharedPreferences.setBool(_themeKey, isDarkMode);
  }
}
