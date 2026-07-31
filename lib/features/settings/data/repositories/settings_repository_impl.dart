import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

part 'settings_repository_impl.g.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remoteDataSource);

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Future<void> clearAllData({void Function(double progress)? onProgress}) =>
      _remoteDataSource.clearAllData(onProgress: onProgress);
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final SettingsRemoteDataSource remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource);
}
