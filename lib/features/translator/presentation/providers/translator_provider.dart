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

  int noPhoto = 0;
  int noAltName = 0;
  int noWebsite = 0;
  int noBooks = 0;
  int noWorks = 0;

  for (final TranslatorEntity t in translators) {
    if (t.image == null || t.image!.trim().isEmpty) {
      noPhoto++;
    }
    if (t.otherName == null || t.otherName!.trim().isEmpty) {
      noAltName++;
    }
    if (t.website == null || t.website!.trim().isEmpty) {
      noWebsite++;
    }
    if (t.bookIds.isEmpty) {
      noBooks++;
    }
    if (t.workIds.isEmpty) {
      noWorks++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Photo', count: noPhoto),
    (label: 'No Alt. Name', count: noAltName),
    (label: 'No Website', count: noWebsite),
    (label: 'No Books', count: noBooks),
    (label: 'No Works', count: noWorks),
  ];
}
