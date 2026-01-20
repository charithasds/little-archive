import '../datasources/sequence_remote_datasource.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../models/sequence_model.dart';

class SequenceRepositoryImpl implements SequenceRepository {
  final SequenceRemoteDataSource remoteDataSource;

  SequenceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SequenceEntity>> getSequences() =>
      remoteDataSource.getSequences();

  @override
  Future<SequenceEntity?> getSequenceById(String id) =>
      remoteDataSource.getSequenceById(id);

  @override
  Future<void> addSequence(SequenceEntity sequence) {
    return remoteDataSource.addSequence(
      SequenceModel(
        id: sequence.id,
        name: sequence.name,
        notes: sequence.notes,
        sequenceVolumeIds: sequence.sequenceVolumeIds,
      ),
    );
  }

  @override
  Future<void> updateSequence(SequenceEntity sequence) {
    return remoteDataSource.updateSequence(
      SequenceModel(
        id: sequence.id,
        name: sequence.name,
        notes: sequence.notes,
        sequenceVolumeIds: sequence.sequenceVolumeIds,
      ),
    );
  }

  @override
  Future<void> deleteSequence(String id) => remoteDataSource.deleteSequence(id);

  @override
  Stream<List<SequenceEntity>> watchSequences() =>
      remoteDataSource.watchSequences();
}
