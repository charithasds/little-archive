import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/settings_repository_impl.dart';
import '../domain/usecases/settings_usecases.dart';

export '../domain/usecases/settings_usecases.dart';

part 'settings_usecase_providers.g.dart';

@riverpod
ClearAllDataUseCase clearAllDataUseCase(Ref ref) =>
    ClearAllDataUseCase(ref.watch(settingsRepositoryProvider));
