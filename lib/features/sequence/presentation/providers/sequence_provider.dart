import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/sequence_remote_datasource.dart';
import '../../data/repositories/sequence_repository_impl.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../../domain/usecases/sequence_usecases.dart';

part 'sequence_provider.g.dart';

@riverpod
SequenceRemoteDataSource _sequenceRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return SequenceRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
SequenceRepository _sequenceRepository(Ref ref) {
  final SequenceRemoteDataSource remoteDataSource = ref.watch(_sequenceRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return SequenceRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GenerateSequenceIdUseCase generateSequenceIdUseCase(Ref ref) =>
    GenerateSequenceIdUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
FetchSequencesUseCase fetchSequencesUseCase(Ref ref) =>
    FetchSequencesUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
FetchSequenceByIdUseCase fetchSequenceByIdUseCase(Ref ref) =>
    FetchSequenceByIdUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
WatchSequencesUseCase watchSequencesUseCase(Ref ref) =>
    WatchSequencesUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
AddSequenceUseCase addSequenceUseCase(Ref ref) =>
    AddSequenceUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
EditSequenceUseCase editSequenceUseCase(Ref ref) =>
    EditSequenceUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
RemoveSequenceUseCase removeSequenceUseCase(Ref ref) =>
    RemoveSequenceUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
GenerateSequenceVolumeIdUseCase generateSequenceVolumeIdUseCase(Ref ref) =>
    GenerateSequenceVolumeIdUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumesUseCase fetchSequenceVolumesUseCase(Ref ref) =>
    FetchSequenceVolumesUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumeByIdUseCase fetchSequenceVolumeByIdUseCase(Ref ref) =>
    FetchSequenceVolumeByIdUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumesByBookIdUseCase fetchSequenceVolumesByBookIdUseCase(Ref ref) =>
    FetchSequenceVolumesByBookIdUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumesByWorkIdUseCase fetchSequenceVolumesByWorkIdUseCase(Ref ref) =>
    FetchSequenceVolumesByWorkIdUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
WatchSequenceVolumesUseCase watchSequenceVolumesUseCase(Ref ref) =>
    WatchSequenceVolumesUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
AddSequenceVolumeUseCase addSequenceVolumeUseCase(Ref ref) =>
    AddSequenceVolumeUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
EditSequenceVolumeUseCase editSequenceVolumeUseCase(Ref ref) =>
    EditSequenceVolumeUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
RemoveSequenceVolumeUseCase removeSequenceVolumeUseCase(Ref ref) =>
    RemoveSequenceVolumeUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
SyncBookSequenceVolumesUseCase syncBookSequenceVolumesUseCase(Ref ref) =>
    SyncBookSequenceVolumesUseCase(ref.watch(_sequenceRepositoryProvider));

@riverpod
SyncWorkSequenceVolumesUseCase syncWorkSequenceVolumesUseCase(Ref ref) =>
    SyncWorkSequenceVolumesUseCase(ref.watch(_sequenceRepositoryProvider));

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
