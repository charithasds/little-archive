import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';

part 'work_provider.g.dart';

@riverpod
Stream<List<WorkEntity>> worksStream(Ref ref) {
  final WatchWorksUseCase watchWorks = ref.watch(watchWorksUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<WorkEntity>>.value(<WorkEntity>[]);
  }

  return watchWorks();
}

@riverpod
int? workCount(Ref ref) => ref.watch(worksStreamProvider).value?.length;

@riverpod
Future<WorkEntity?> work(Ref ref, String id) async {
  final List<WorkEntity> works = await ref.watch(worksStreamProvider.future);

  try {
    return works.firstWhere((WorkEntity w) => w.id == id);
  } catch (_) {
    return null;
  }
}

// ── Work missing-info provider ─────────────────────────────────────────────

@riverpod
List<({String label, int count})>? worksMissingInfo(Ref ref) {
  final List<WorkEntity>? works = ref.watch(worksStreamProvider).value;
  if (works == null) {
    return null;
  }

  int noAuthors = 0;
  int noTranslators = 0;
  int noOriginalTitle = 0;
  int noLanguage = 0;
  int noOriginalLanguage = 0;
  int noGenre = 0;
  int noSequences = 0;

  for (final WorkEntity w in works) {
    if (w.authorIds.isEmpty) {
      noAuthors++;
    }
    if (w.isTranslation) {
      if (w.translatorIds.isEmpty) {
        noTranslators++;
      }
      if (w.originalTitle == null || w.originalTitle!.trim().isEmpty) {
        noOriginalTitle++;
      }
      if (w.originalLanguage == null) {
        noOriginalLanguage++;
      }
    }
    if (w.language == null) {
      noLanguage++;
    }
    if (w.genre == null) {
      noGenre++;
    }
    if (w.sequenceVolumeIds.isEmpty) {
      noSequences++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Authors', count: noAuthors),
    (label: 'No Translators', count: noTranslators),
    (label: 'No Original Title', count: noOriginalTitle),
    (label: 'No Language', count: noLanguage),
    (label: 'No Orig. Language', count: noOriginalLanguage),
    (label: 'No Genre', count: noGenre),
    (label: 'No Sequences', count: noSequences),
  ];
}
