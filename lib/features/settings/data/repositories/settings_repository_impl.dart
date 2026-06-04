import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

part 'settings_repository_impl.g.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remoteDataSource);

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Future<void> clearAllData() => _remoteDataSource.clearAllData();
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final SettingsRemoteDataSource remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource);
}
