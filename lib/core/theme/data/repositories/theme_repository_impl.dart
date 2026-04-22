import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/presentation/providers/shared_preferences_provider.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this.localDataSource);

  final ThemeLocalDataSource localDataSource;

  @override
  Future<bool> fetchIsDarkMode() async => localDataSource.fetchIsDarkMode();

  @override
  Future<void> setIsDarkMode(bool isDarkMode) async {
    await localDataSource.setIsDarkMode(isDarkMode);
  }
}

final Provider<ThemeLocalDataSource?> themeLocalDataSourceProvider =
    Provider<ThemeLocalDataSource?>((Ref ref) {
      final SharedPreferences? prefs = ref.watch(sharedPreferencesProvider).asData?.value;

      return prefs != null ? ThemeLocalDataSource(prefs) : null;
    });

final Provider<ThemeRepository?> themeRepositoryProvider = Provider<ThemeRepository?>((Ref ref) {
  final ThemeLocalDataSource? localDataSource = ref.watch(themeLocalDataSourceProvider);

  return localDataSource != null ? ThemeRepositoryImpl(localDataSource) : null;
});
