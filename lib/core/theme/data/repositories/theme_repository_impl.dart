import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/presentation/providers/shared_preferences_provider.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

/// Implementation of [ThemeRepository] that uses [ThemeLocalDataSource] for persistence.
class ThemeRepositoryImpl implements ThemeRepository {
  /// Creates a [ThemeRepositoryImpl] with the required [localDataSource].
  ThemeRepositoryImpl(this.localDataSource);

  /// The local data source for theme settings.
  final ThemeLocalDataSource localDataSource;

  @override
  Future<bool> getIsDarkMode() async => localDataSource.getIsDarkMode();

  @override
  Future<void> setIsDarkMode(bool isDarkMode) async {
    await localDataSource.setIsDarkMode(isDarkMode);
  }
}

/// Provider for [ThemeLocalDataSource].
/// Null until [sharedPreferencesProvider] resolves.
final Provider<ThemeLocalDataSource?> themeLocalDataSourceProvider =
    Provider<ThemeLocalDataSource?>((Ref ref) {
      final SharedPreferences? prefs = ref.watch(sharedPreferencesProvider).asData?.value;

      return prefs != null ? ThemeLocalDataSource(prefs) : null;
    });

/// Provider for [ThemeRepository].
/// Null until [themeLocalDataSourceProvider] is ready.
final Provider<ThemeRepository?> themeRepositoryProvider = Provider<ThemeRepository?>((Ref ref) {
  final ThemeLocalDataSource? localDataSource = ref.watch(themeLocalDataSourceProvider);

  return localDataSource != null ? ThemeRepositoryImpl(localDataSource) : null;
});
