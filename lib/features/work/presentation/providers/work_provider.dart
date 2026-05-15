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

  int countWhere(bool Function(WorkEntity) test) => works.where(test).length;

  final List<WorkEntity> translations = works.where((WorkEntity w) => w.isTranslation).toList();

  return <({String label, int count})>[
    (label: 'No Authors', count: countWhere((WorkEntity w) => w.authorIds.isEmpty)),
    (
      label: 'No Translators',
      count: translations.where((WorkEntity w) => w.translatorIds.isEmpty).length,
    ),
    (
      label: 'No Original Title',
      count: translations
          .where((WorkEntity w) => w.originalTitle == null || w.originalTitle!.trim().isEmpty)
          .length,
    ),
    (label: 'No Language', count: countWhere((WorkEntity w) => w.language == null)),
    (
      label: 'No Orig. Language',
      count: translations.where((WorkEntity w) => w.originalLanguage == null).length,
    ),
    (label: 'No Genre', count: countWhere((WorkEntity w) => w.genre == null)),
    (label: 'No Sequences', count: countWhere((WorkEntity w) => w.sequenceVolumeIds.isEmpty)),
  ];
}
