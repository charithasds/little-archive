import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/presentation/providers/firestore_provider.dart';
import '../../data/datasources/sequence_remote_datasource.dart';
import '../../data/repositories/sequence_repository_impl.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_repository.dart';

final Provider<SequenceRemoteDataSource> sequenceRemoteDataSourceProvider =
    Provider<SequenceRemoteDataSource>((Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return SequenceRemoteDataSourceImpl(firestoreService: firestoreService);
    });

final Provider<SequenceRepository> sequenceRepositoryProvider = Provider<SequenceRepository>((
  Ref ref,
) {
  final SequenceRemoteDataSource remoteDataSource = ref.watch(sequenceRemoteDataSourceProvider);
  return SequenceRepositoryImpl(remoteDataSource: remoteDataSource);
});

final StreamProvider<List<SequenceEntity>> sequencesStreamProvider =
    StreamProvider<List<SequenceEntity>>((Ref ref) {
      final SequenceRepository repository = ref.watch(sequenceRepositoryProvider);
      final UserEntity? user = ref.watch(authStateProvider).value;
      if (user == null) {
        return Stream<List<SequenceEntity>>.value(<SequenceEntity>[]);
      }
      return repository.watchSequences(user.uid);
    });

// ignore: always_specify_types
final sequenceVolumesStreamProvider = StreamProvider.family<List<SequenceVolumeEntity>, String>((
  Ref ref,
  String sequenceId,
) {
  final SequenceRepository repository = ref.watch(sequenceRepositoryProvider);
  final UserEntity? user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream<List<SequenceVolumeEntity>>.value(<SequenceVolumeEntity>[]);
  }
  return repository.watchSequenceVolumes(sequenceId, user.uid);
});

class SequenceStats {
  const SequenceStats({this.bookCount = 0, this.workCount = 0});
  final int bookCount;
  final int workCount;
}

// ignore: always_specify_types
final sequenceStatsProvider = Provider.family<SequenceStats, String>((Ref ref, String sequenceId) {
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
});
