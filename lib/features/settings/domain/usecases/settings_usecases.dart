import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../repositories/settings_repository.dart';

part 'settings_usecases.g.dart';

class ClearAllDataUseCase {
  const ClearAllDataUseCase(this.repository);
  final SettingsRepository repository;

  Future<void> call({void Function(double progress)? onProgress}) =>
      repository.clearAllData(onProgress: onProgress);
}

@riverpod
ClearAllDataUseCase clearAllDataUseCase(Ref ref) =>
    ClearAllDataUseCase(ref.watch(settingsRepositoryProvider));
