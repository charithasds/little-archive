import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/sequence_remote_datasource.dart';
import '../../data/repositories/sequence_repository_impl.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_repository.dart';

final Provider<SequenceRemoteDataSource> sequenceRemoteDataSourceProvider =
    Provider<SequenceRemoteDataSource>((Ref ref) {
      final FirebaseFirestore firestore = ref.watch(firestoreProvider);
      return SequenceRemoteDataSourceImpl(firestore: firestore);
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

/// Family provider to watch sequence volumes for a specific sequence
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

/// Helper class to hold book and work counts for a sequence
class SequenceStats {
  const SequenceStats({this.bookCount = 0, this.workCount = 0});
  final int bookCount;
  final int workCount;
}

/// Family provider to compute book and work counts for a sequence
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
