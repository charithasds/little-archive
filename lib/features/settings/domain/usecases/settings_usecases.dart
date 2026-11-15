import '../repositories/settings_repository.dart';

class ClearAllDataUseCase {
  const ClearAllDataUseCase(this.repository);
  final SettingsRepository repository;

  Future<void> call({void Function(double progress)? onProgress}) =>
      repository.clearAllData(onProgress: onProgress);
}
