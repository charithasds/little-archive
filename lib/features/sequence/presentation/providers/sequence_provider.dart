import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/sequence_remote_datasource.dart';
import '../../data/repositories/sequence_repository_impl.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final sequenceRemoteDataSourceProvider = Provider<SequenceRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return SequenceRemoteDataSourceImpl(firestore: firestore);
});

final sequenceRepositoryProvider = Provider<SequenceRepository>((ref) {
  final remoteDataSource = ref.watch(sequenceRemoteDataSourceProvider);
  return SequenceRepositoryImpl(remoteDataSource: remoteDataSource);
});

final sequencesStreamProvider = StreamProvider<List<SequenceEntity>>((ref) {
  final repository = ref.watch(sequenceRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return repository.watchSequences(user.uid);
});

/// Family provider to watch sequence volumes for a specific sequence
final sequenceVolumesStreamProvider =
    StreamProvider.family<List<SequenceVolumeEntity>, String>((
      ref,
      sequenceId,
    ) {
      final repository = ref.watch(sequenceRepositoryProvider);
      final user = ref.watch(authStateProvider).value;
      if (user == null) return Stream.value([]);
      return repository.watchSequenceVolumes(sequenceId, user.uid);
    });

/// Helper class to hold book and work counts for a sequence
class SequenceStats {
  final int bookCount;
  final int workCount;

  const SequenceStats({this.bookCount = 0, this.workCount = 0});
}

/// Family provider to compute book and work counts for a sequence
final sequenceStatsProvider = Provider.family<SequenceStats, String>((
  ref,
  sequenceId,
) {
  final volumesAsync = ref.watch(sequenceVolumesStreamProvider(sequenceId));
  return volumesAsync.when(
    data: (volumes) {
      int bookCount = 0;
      int workCount = 0;
      for (final volume in volumes) {
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
