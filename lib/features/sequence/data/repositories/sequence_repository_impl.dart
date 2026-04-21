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
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<SequenceEntity>> getSequences() => remoteDataSource.fetchSequences();

  @override
  Future<SequenceEntity?> getSequenceById(String id) => remoteDataSource.fetchSequenceById(id);

  @override
  Stream<List<SequenceEntity>> watchSequences() => remoteDataSource.watchSequences();

  @override
  Future<void> addSequence(SequenceEntity sequence) => remoteDataSource.addSequence(
        SequenceModel(
          id: sequence.id,
          name: sequence.name,
          otherName: sequence.otherName,
          notes: sequence.notes,
          sequenceVolumeIds: sequence.sequenceVolumeIds,
          createdDate: sequence.createdDate,
          lastUpdated: sequence.lastUpdated,
        ),
      );

  @override
  Future<void> editSequence(SequenceEntity sequence) => remoteDataSource.editSequence(
        SequenceModel(
          id: sequence.id,
          name: sequence.name,
          otherName: sequence.otherName,
          notes: sequence.notes,
          sequenceVolumeIds: sequence.sequenceVolumeIds,
          createdDate: sequence.createdDate,
          lastUpdated: sequence.lastUpdated,
        ),
      );

  @override
  Future<void> removeSequence(String id) => remoteDataSource.removeSequence(id);

  @override
  String generateVolumeId() => remoteDataSource.generateVolumeId();

  @override
  Future<List<SequenceVolumeEntity>> getSequenceVolumes(String sequenceId) =>
      remoteDataSource.fetchSequenceVolumes(sequenceId);

  @override
  Future<SequenceVolumeEntity?> getSequenceVolumeById(String id) =>
      remoteDataSource.fetchSequenceVolumeById(id);

  @override
  Future<List<SequenceVolumeEntity>> getSequenceVolumesByBookId(String bookId) =>
      remoteDataSource.fetchSequenceVolumesByBookId(bookId);

  @override
  Future<List<SequenceVolumeEntity>> getSequenceVolumesByWorkId(String workId) =>
      remoteDataSource.fetchSequenceVolumesByWorkId(workId);

  @override
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(String sequenceId) =>
      remoteDataSource.watchSequenceVolumes(sequenceId);

  @override
  Future<void> addSequenceVolume(SequenceVolumeEntity volume) => remoteDataSource.addSequenceVolume(
        SequenceVolumeModel(
          id: volume.id,
          volume: volume.volume,
          sequenceId: volume.sequenceId,
          bookId: volume.bookId,
          workId: volume.workId,
          createdDate: volume.createdDate,
          lastUpdated: volume.lastUpdated,
        ),
      );

  @override
  Future<void> editSequenceVolume(SequenceVolumeEntity volume) =>
      remoteDataSource.editSequenceVolume(
        SequenceVolumeModel(
          id: volume.id,
          volume: volume.volume,
          sequenceId: volume.sequenceId,
          bookId: volume.bookId,
          workId: volume.workId,
          createdDate: volume.createdDate,
          lastUpdated: volume.lastUpdated,
        ),
      );

  @override
  Future<void> removeSequenceVolume(String id) => remoteDataSource.removeSequenceVolume(id);
}
