import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/usecases/sequence_usecases.dart';
import '../../domain/usecases/sequence_volume_usecases.dart';

part 'sequence_provider.g.dart';

@riverpod
Stream<List<SequenceEntity>> sequencesStream(Ref ref) {
  final WatchSequencesUseCase watchSequences = ref.watch(watchSequencesUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<SequenceEntity>>.value(<SequenceEntity>[]);
  }

  return watchSequences();
}

@riverpod
Future<int> sequenceCount(Ref ref) async {
  final String? userId = ref.watch(currentUidProvider);
  if (userId == null) {
    return 0;
  }
  final FirebaseFirestore firestore = ref.watch(firestoreServiceProvider).firebaseFirestore;
  final AggregateQuerySnapshot snap = await firestore.collection('users/$userId/sequences').count().get();
  return snap.count ?? 0;
}


@riverpod
Future<SequenceEntity?> sequence(Ref ref, String id) async {
  final List<SequenceEntity> sequences = await ref.watch(sequencesStreamProvider.future);

  try {
    return sequences.firstWhere((SequenceEntity s) => s.id == id);
  } catch (_) {
    return null;
  }
}

// ── Sequence missing-info provider ───────────────────────────────────

@riverpod
List<({String label, int count})>? sequencesMissingInfo(Ref ref) {
  final List<SequenceEntity>? sequences = ref.watch(sequencesStreamProvider).value;
  if (sequences == null) {
    return null;
  }

  int noVolumes = 0;

  for (final SequenceEntity s in sequences) {
    if (s.sequenceVolumeIds.isEmpty) {
      noVolumes++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Volumes', count: noVolumes),
  ];
}

@riverpod
Future<SequenceVolumeEntity?> sequenceVolume(Ref ref, String id) async {
  final FetchSequenceVolumeByIdUseCase fetchVolume = ref.watch(
    fetchSequenceVolumeByIdUseCaseProvider,
  );
  return fetchVolume(id);
}

@riverpod
Stream<List<SequenceVolumeEntity>> sequenceVolumesStream(Ref ref, String sequenceId) {
  final WatchSequenceVolumesUseCase watchVolumes = ref.watch(watchSequenceVolumesUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<SequenceVolumeEntity>>.value(<SequenceVolumeEntity>[]);
  }

  return watchVolumes(sequenceId);
}

@riverpod
Stream<List<SequenceVolumeEntity>> allSequenceVolumesStream(Ref ref) {
  final WatchAllSequenceVolumesUseCase watchVolumes = ref.watch(
    watchAllSequenceVolumesUseCaseProvider,
  );
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<SequenceVolumeEntity>>.value(<SequenceVolumeEntity>[]);
  }

  return watchVolumes();
}

class SequenceStats {
  const SequenceStats({this.bookCount = 0, this.workCount = 0});

  final int bookCount;
  final int workCount;
}

@riverpod
SequenceStats sequenceStats(Ref ref, String sequenceId) {
  final AsyncValue<List<SequenceVolumeEntity>> volumesAsync = ref.watch(
    sequenceVolumesStreamProvider(sequenceId),
  );

  return volumesAsync.when(
    data: (List<SequenceVolumeEntity> volumes) {
      int bookCount = 0;
      int workCount = 0;

      for (final SequenceVolumeEntity volume in volumes) {
        if (volume.bookId != null && volume.bookId!.isNotEmpty) {
          bookCount++;
        }
        if (volume.workId != null && volume.workId!.isNotEmpty) {
          workCount++;
        }
      }

      return SequenceStats(bookCount: bookCount, workCount: workCount);
    },
    loading: () => const SequenceStats(),
    error: (_, _) => const SequenceStats(),
  );
}
