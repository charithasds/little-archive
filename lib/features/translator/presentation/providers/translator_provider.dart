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
Future<int> translatorCount(Ref ref) async {
  final FetchTranslatorCountUseCase fetchTranslatorCount = ref.watch(
    fetchTranslatorCountUseCaseProvider,
  );
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return 0;
  }

  return fetchTranslatorCount();
}

@riverpod
Future<String?> translatorName(Ref ref, String id) async {
  final FetchTranslatorByIdUseCase fetchTranslator = ref.watch(fetchTranslatorByIdUseCaseProvider);
  final TranslatorEntity? translator = await fetchTranslator(id);
  return translator?.name;
}
