import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeLocalDataSource {
  bool fetchIsDarkMode();

  Future<void> setIsDarkMode(bool isDarkMode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  ThemeLocalDataSourceImpl(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static const String _themeKey = 'is_dark_mode';

  @override
  bool fetchIsDarkMode() => _sharedPreferences.getBool(_themeKey) ?? false;

  @override
  Future<void> setIsDarkMode(bool isDarkMode) async {
    await _sharedPreferences.setBool(_themeKey, isDarkMode);
  }
}
