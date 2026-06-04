import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sequence_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../datasources/sequence_remote_datasource.dart';
import '../models/sequence_model.dart';

part 'sequence_repository_impl.g.dart';

class SequenceRepositoryImpl implements SequenceRepository {
  SequenceRepositoryImpl({required this.remoteDataSource});

  final SequenceRemoteDataSource remoteDataSource;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<SequenceEntity>> fetchSequences() => remoteDataSource.fetchSequences();

  @override
  Future<SequenceEntity?> fetchSequenceById(String id) => remoteDataSource.fetchSequenceById(id);

  @override
  Stream<List<SequenceEntity>> watchSequences() => remoteDataSource.watchSequences();

  @override
  Future<void> addSequence(SequenceEntity sequence) async {
    await remoteDataSource.addSequence(
      SequenceModel(
        id: sequence.id,
        name: sequence.name,
        notes: sequence.notes,
        sequenceVolumeIds: sequence.sequenceVolumeIds,
        createdDate: sequence.createdDate,
        lastUpdated: sequence.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editSequence(SequenceEntity sequence, {SequenceEntity? oldSequence}) async {
    await remoteDataSource.editSequence(
      SequenceModel(
        id: sequence.id,
        name: sequence.name,
        notes: sequence.notes,
        sequenceVolumeIds: sequence.sequenceVolumeIds,
        createdDate: sequence.createdDate,
        lastUpdated: sequence.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removeSequence(String id) async {
    await remoteDataSource.removeSequence(id);
  }
}

@riverpod
SequenceRepository sequenceRepository(Ref ref) {
  final SequenceRemoteDataSource remoteDataSource = ref.watch(sequenceRemoteDataSourceProvider);

  return SequenceRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
