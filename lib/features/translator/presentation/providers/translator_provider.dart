import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/translator_entity.dart';
import '../../domain/usecases/translator_usecases.dart';

part 'translator_provider.g.dart';

@riverpod
Stream<List<TranslatorEntity>> translatorsStream(Ref ref) {
  final WatchTranslatorsUseCase watchTranslators = ref.watch(watchTranslatorsUseCaseProvider);
  return watchTranslators();
}

@riverpod
Future<int> translatorCount(Ref ref) async {
  final List<TranslatorEntity> translators = await ref.watch(translatorsStreamProvider.future);
  return translators.length;
}

@riverpod
AsyncValue<TranslatorEntity?> translator(Ref ref, String id) {
  final AsyncValue<List<TranslatorEntity>> stream = ref.watch(translatorsStreamProvider);
  return stream.when(
    data: (List<TranslatorEntity> list) {
      try {
        return AsyncValue<TranslatorEntity?>.data(list.firstWhere((TranslatorEntity t) => t.id == id));
      } catch (_) {
        return const AsyncValue<TranslatorEntity?>.data(null);
      }
    },
    error: (Object e, StackTrace s) => AsyncValue<TranslatorEntity?>.error(e, s),
    loading: () => const AsyncValue<TranslatorEntity?>.loading(),
  );
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
