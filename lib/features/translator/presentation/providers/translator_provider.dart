import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/usecases/translator_usecases.dart';

part 'translator_provider.g.dart';

@riverpod
Stream<List<TranslatorEntity>> translatorsStream(Ref ref) {
  final WatchTranslatorsUseCase watchTranslators = ref.watch(watchTranslatorsUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<TranslatorEntity>>.value(<TranslatorEntity>[]);
  }

  return watchTranslators();
}

@riverpod
int? translatorCount(Ref ref) => ref.watch(translatorsStreamProvider).value?.length;

@riverpod
Future<TranslatorEntity?> translator(Ref ref, String id) async {
  final List<TranslatorEntity> translators = await ref.watch(translatorsStreamProvider.future);

  try {
    return translators.firstWhere((TranslatorEntity t) => t.id == id);
  } catch (_) {
    return null;
  }
}
