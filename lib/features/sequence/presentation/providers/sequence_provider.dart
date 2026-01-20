import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/sequence_remote_datasource.dart';
import '../../data/repositories/sequence_repository_impl.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../../domain/entities/sequence_entity.dart';

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
  return repository.watchSequences();
});
