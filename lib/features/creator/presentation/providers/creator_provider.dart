import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/creator_entity.dart';
import '../../domain/usecases/creator_usecases.dart';

part 'creator_provider.g.dart';

@riverpod
Stream<List<CreatorEntity>> creatorsStream(Ref ref) {
  final WatchCreatorsUseCase watchCreators = ref.watch(watchCreatorsUseCaseProvider);
  return watchCreators();
}

@riverpod
Future<int> creatorCount(Ref ref) async {
  final List<CreatorEntity> creators = await ref.watch(creatorsStreamProvider.future);
  return creators.length;
}

@riverpod
AsyncValue<CreatorEntity?> creator(Ref ref, String id) {
  final AsyncValue<List<CreatorEntity>> stream = ref.watch(creatorsStreamProvider);
  return stream.when(
    data: (List<CreatorEntity> list) {
      try {
        return AsyncValue<CreatorEntity?>.data(list.firstWhere((CreatorEntity a) => a.id == id));
      } catch (_) {
        return const AsyncValue<CreatorEntity?>.data(null);
      }
    },
    error: (Object e, StackTrace s) => AsyncValue<CreatorEntity?>.error(e, s),
    loading: () => const AsyncValue<CreatorEntity?>.loading(),
  );
}

// ── Creator missing-info provider ─────────────────────────────────────────

@riverpod
List<({String label, int count})>? creatorsMissingInfo(Ref ref) {
  final List<CreatorEntity>? creators = ref.watch(creatorsStreamProvider).value;
  if (creators == null) {
    return null;
  }

  int noPhoto = 0;
  int noAltName = 0;
  int noWebsite = 0;
  int noBooks = 0;
  int noWorks = 0;

  for (final CreatorEntity a in creators) {
    if (a.image == null || a.image!.trim().isEmpty) {
      noPhoto++;
    }
    if (a.otherName == null || a.otherName!.trim().isEmpty) {
      noAltName++;
    }
    if (a.website == null || a.website!.trim().isEmpty) {
      noWebsite++;
    }
    if (a.authoredBookIds.isEmpty && a.translatedBookIds.isEmpty) {
      noBooks++;
    }
    if (a.authoredWorkIds.isEmpty && a.translatedWorkIds.isEmpty) {
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
