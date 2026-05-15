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

// ── Translator missing-info provider ────────────────────────────────────

@riverpod
List<({String label, int count})>? translatorsMissingInfo(Ref ref) {
  final List<TranslatorEntity>? translators = ref.watch(translatorsStreamProvider).value;
  if (translators == null) {
    return null;
  }

  int countWhere(bool Function(TranslatorEntity) test) => translators.where(test).length;

  return <({String label, int count})>[
    (
      label: 'No Photo',
      count: countWhere((TranslatorEntity t) => t.image == null || t.image!.trim().isEmpty),
    ),
    (
      label: 'No Alt. Name',
      count: countWhere((TranslatorEntity t) => t.otherName == null || t.otherName!.trim().isEmpty),
    ),
    (
      label: 'No Website',
      count: countWhere((TranslatorEntity t) => t.website == null || t.website!.trim().isEmpty),
    ),
    (label: 'No Books', count: countWhere((TranslatorEntity t) => t.bookIds.isEmpty)),
    (label: 'No Works', count: countWhere((TranslatorEntity t) => t.workIds.isEmpty)),
  ];
}
