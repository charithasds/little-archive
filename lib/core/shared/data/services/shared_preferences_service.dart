import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<SharedPreferences> initialize() async => SharedPreferences.getInstance();
}
