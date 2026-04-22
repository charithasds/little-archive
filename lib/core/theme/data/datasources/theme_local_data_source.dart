import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  ThemeLocalDataSource(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static const String _themeKey = 'is_dark_mode';

  bool fetchIsDarkMode() => _sharedPreferences.getBool(_themeKey) ?? false;

  Future<void> setIsDarkMode(bool isDarkMode) async {
    await _sharedPreferences.setBool(_themeKey, isDarkMode);
  }
}
