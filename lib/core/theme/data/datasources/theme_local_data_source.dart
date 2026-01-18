import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  final SharedPreferences sharedPreferences;

  ThemeLocalDataSource(this.sharedPreferences);

  static const String _themeKey = 'is_dark_mode';

  bool getIsDarkMode() {
    return sharedPreferences.getBool(_themeKey) ?? false;
  }

  Future<void> setIsDarkMode(bool isDarkMode) async {
    await sharedPreferences.setBool(_themeKey, isDarkMode);
  }
}
