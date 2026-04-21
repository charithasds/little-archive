import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../data/datasources/sequence_remote_datasource.dart';
import '../../data/repositories/sequence_repository_impl.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../../domain/usecases/sequence_usecases.dart';

part 'sequence_provider.g.dart';

@riverpod
SequenceRemoteDataSource sequenceRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return SequenceRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
SequenceRepository sequenceRepository(Ref ref) {
  final SequenceRemoteDataSource remoteDataSource = ref.watch(sequenceRemoteDataSourceProvider);

  return SequenceRepositoryImpl(remoteDataSource: remoteDataSource);
}

@riverpod
GetSequencesUseCase getSequencesUseCase(Ref ref) =>
    GetSequencesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
WatchSequencesUseCase watchSequencesUseCase(Ref ref) =>
    WatchSequencesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceByIdUseCase getSequenceByIdUseCase(Ref ref) =>
    GetSequenceByIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
AddSequenceUseCase addSequenceUseCase(Ref ref) =>
    AddSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
EditSequenceUseCase editSequenceUseCase(Ref ref) =>
    EditSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
RemoveSequenceUseCase removeSequenceUseCase(Ref ref) =>
    RemoveSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceVolumeByIdUseCase getSequenceVolumeByIdUseCase(Ref ref) =>
    GetSequenceVolumeByIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceVolumesByBookIdUseCase getSequenceVolumesByBookIdUseCase(Ref ref) =>
    GetSequenceVolumesByBookIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceVolumesByWorkIdUseCase getSequenceVolumesByWorkIdUseCase(Ref ref) =>
    GetSequenceVolumesByWorkIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceVolumesUseCase getSequenceVolumesUseCase(Ref ref) =>
    GetSequenceVolumesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
AddSequenceVolumeUseCase addSequenceVolumeUseCase(Ref ref) =>
    AddSequenceVolumeUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
EditSequenceVolumeUseCase editSequenceVolumeUseCase(Ref ref) =>
    EditSequenceVolumeUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
RemoveSequenceVolumeUseCase removeSequenceVolumeUseCase(Ref ref) =>
    RemoveSequenceVolumeUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
WatchSequenceVolumesUseCase watchSequenceVolumesUseCase(Ref ref) =>
    WatchSequenceVolumesUseCase(ref.watch(sequenceRepositoryProvider));

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
