import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/usecases/sequence_usecases.dart';

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
int? sequenceCount(Ref ref) => ref.watch(sequencesStreamProvider).value?.length;

@riverpod
Future<SequenceEntity?> sequence(Ref ref, String id) async {
  final List<SequenceEntity> sequences = await ref.watch(sequencesStreamProvider.future);

  try {
    return sequences.firstWhere((SequenceEntity s) => s.id == id);
  } catch (_) {
    return null;
  }
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
