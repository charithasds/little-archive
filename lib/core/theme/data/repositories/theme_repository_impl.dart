import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this.localDataSource);
  final ThemeLocalDataSource localDataSource;

  @override
  Future<bool> getIsDarkMode() async => localDataSource.getIsDarkMode();

  @override
  Future<void> setIsDarkMode(bool isDarkMode) async {
    await localDataSource.setIsDarkMode(isDarkMode);
  }
}
