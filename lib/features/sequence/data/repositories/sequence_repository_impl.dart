import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../datasources/sequence_remote_datasource.dart';
import '../models/sequence_model.dart';
import '../models/sequence_volume_model.dart';

class SequenceRepositoryImpl implements SequenceRepository {
  SequenceRepositoryImpl({required this.remoteDataSource});
  final SequenceRemoteDataSource remoteDataSource;

  @override
  Future<List<SequenceEntity>> getSequences(String userId) => remoteDataSource.getSequences(userId);

  @override
  Future<SequenceEntity?> getSequenceById(String id) => remoteDataSource.getSequenceById(id);

  @override
  Future<void> addSequence(SequenceEntity sequence) => remoteDataSource.addSequence(
    SequenceModel(
      id: sequence.id,
      userId: sequence.userId,
      name: sequence.name,
      notes: sequence.notes,
      sequenceVolumeIds: sequence.sequenceVolumeIds,
    ),
  );

  @override
  Future<void> updateSequence(SequenceEntity sequence) => remoteDataSource.updateSequence(
    SequenceModel(
      id: sequence.id,
      userId: sequence.userId,
      name: sequence.name,
      notes: sequence.notes,
      sequenceVolumeIds: sequence.sequenceVolumeIds,
    ),
  );

  @override
  Future<void> deleteSequence(String id) => remoteDataSource.deleteSequence(id);

  @override
  Stream<List<SequenceEntity>> watchSequences(String userId) =>
      remoteDataSource.watchSequences(userId);

  @override
  Future<List<SequenceVolumeEntity>> getSequenceVolumes(String sequenceId, String userId) =>
      remoteDataSource.getSequenceVolumes(sequenceId, userId);

  @override
  Future<void> addSequenceVolume(SequenceVolumeEntity volume) => remoteDataSource.addSequenceVolume(
    SequenceVolumeModel(
      id: volume.id,
      userId: volume.userId,
      volume: volume.volume,
      sequenceId: volume.sequenceId,
      bookId: volume.bookId,
      workId: volume.workId,
      createdDate: volume.createdDate,
      lastUpdated: volume.lastUpdated,
    ),
  );

  @override
  Future<void> updateSequenceVolume(SequenceVolumeEntity volume) =>
      remoteDataSource.updateSequenceVolume(
        SequenceVolumeModel(
          id: volume.id,
          userId: volume.userId,
          volume: volume.volume,
          sequenceId: volume.sequenceId,
          bookId: volume.bookId,
          workId: volume.workId,
          createdDate: volume.createdDate,
          lastUpdated: volume.lastUpdated,
        ),
      );

  @override
  Future<void> deleteSequenceVolume(String id) => remoteDataSource.deleteSequenceVolume(id);

  @override
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(String sequenceId, String userId) =>
      remoteDataSource.watchSequenceVolumes(sequenceId, userId);
}
