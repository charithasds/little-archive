import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
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
  return SequenceRemoteDataSourceImpl(firestoreService: firestoreService);
}

@riverpod
SequenceRepository sequenceRepository(Ref ref) {
  final SequenceRemoteDataSource remoteDataSource = ref.watch(sequenceRemoteDataSourceProvider);
  return SequenceRepositoryImpl(remoteDataSource: remoteDataSource);
}

@riverpod
GetSequencesUseCase getSequencesUseCase(Ref ref) => GetSequencesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
WatchSequencesUseCase watchSequencesUseCase(Ref ref) => WatchSequencesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
AddSequenceUseCase addSequenceUseCase(Ref ref) => AddSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
UpdateSequenceUseCase updateSequenceUseCase(Ref ref) => UpdateSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
DeleteSequenceUseCase deleteSequenceUseCase(Ref ref) => DeleteSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceVolumeByIdUseCase getSequenceVolumeByIdUseCase(Ref ref) => GetSequenceVolumeByIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceVolumesByBookIdUseCase getSequenceVolumesByBookIdUseCase(Ref ref) => GetSequenceVolumesByBookIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GetSequenceVolumesByWorkIdUseCase getSequenceVolumesByWorkIdUseCase(Ref ref) => GetSequenceVolumesByWorkIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
Stream<List<SequenceEntity>> sequencesStream(Ref ref) async* {
  final UserEntity? user = ref.watch(authStateProvider).value;
  if (user == null) {
    yield <SequenceEntity>[];
  } else {
    final WatchSequencesUseCase watchSequences = ref.watch(watchSequencesUseCaseProvider);
    yield* await watchSequences(user.uid);
  }
}

@riverpod
Stream<List<SequenceVolumeEntity>> sequenceVolumesStream(Ref ref, String sequenceId) {
  final SequenceRepository repository = ref.watch(sequenceRepositoryProvider);
  final UserEntity? user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream<List<SequenceVolumeEntity>>.value(<SequenceVolumeEntity>[]);
  }
  return repository.watchSequenceVolumes(sequenceId, user.uid);
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
