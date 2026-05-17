import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

part 'settings_repository_impl.g.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remoteDataSource);

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Future<void> clearAllData() => _remoteDataSource.clearAllData();

  @override
  Future<void> deleteAccount() async {
    // TODO(charithasds): Implement delete account logic.
    // This should include:
    // 1. Deleting all user data (can reuse clearAllData).
    // 2. Deleting the user record in Firestore.
    // 3. Deleting the user account in Firebase Auth.
    throw UnimplementedError('deleteAccount() has not been implemented yet.');
  }
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final SettingsRemoteDataSource remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource);
}
