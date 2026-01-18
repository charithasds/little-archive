import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl(this.localDataSource);

  @override
  Future<bool> getIsDarkMode() async {
    return localDataSource.getIsDarkMode();
  }

  @override
  Future<void> setIsDarkMode(bool isDarkMode) async {
    await localDataSource.setIsDarkMode(isDarkMode);
  }
}
