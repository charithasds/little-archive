import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../repositories/settings_repository.dart';

part 'settings_usecases.g.dart';

class ClearAllDataUseCase {
  const ClearAllDataUseCase(this.repository);
  final SettingsRepository repository;

  Future<void> call() => repository.clearAllData();
}

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this.repository);
  final SettingsRepository repository;

  Future<void> call() => repository.deleteAccount();
}

@riverpod
ClearAllDataUseCase clearAllDataUseCase(Ref ref) =>
    ClearAllDataUseCase(ref.watch(settingsRepositoryProvider));

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) =>
    DeleteAccountUseCase(ref.watch(settingsRepositoryProvider));
