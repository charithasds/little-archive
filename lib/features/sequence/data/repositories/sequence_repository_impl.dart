import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../datasources/sequence_remote_datasource.dart';
import '../models/sequence_model.dart';
import '../models/sequence_volume_model.dart';

class SequenceRepositoryImpl implements SequenceRepository {
  SequenceRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});

  final SequenceRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

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
        otherName: sequence.otherName,
        notes: sequence.notes,
        sequenceVolumeIds: sequence.sequenceVolumeIds,
        createdDate: sequence.createdDate,
        lastUpdated: sequence.lastUpdated,
      ),
    );

    await relationshipSyncService.syncSequenceRelationships(
      sequenceId: sequence.id,
      newSequenceVolumeIds: sequence.sequenceVolumeIds,
    );
  }

  @override
  Future<void> editSequence(SequenceEntity sequence) async {
    final SequenceModel? existingSequence = await remoteDataSource.fetchSequenceById(sequence.id);

    await remoteDataSource.editSequence(
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

    await relationshipSyncService.syncSequenceRelationships(
      sequenceId: sequence.id,
      newSequenceVolumeIds: sequence.sequenceVolumeIds,
      oldSequenceVolumeIds: existingSequence?.sequenceVolumeIds ?? <String>[],
    );
  }

  @override
  Future<void> removeSequence(String id) async {
    final SequenceModel? existingSequence = await remoteDataSource.fetchSequenceById(id);

    if (existingSequence != null) {
      await relationshipSyncService.removeSequenceRelationships(
        sequenceId: id,
        sequenceVolumeIds: existingSequence.sequenceVolumeIds,
      );
    }

    await remoteDataSource.removeSequence(id);
  }

  @override
  String generateVolumeId() => remoteDataSource.generateVolumeId();

  @override
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumes(String sequenceId) =>
      remoteDataSource.fetchSequenceVolumes(sequenceId);

  @override
  Future<SequenceVolumeEntity?> fetchSequenceVolumeById(String id) =>
      remoteDataSource.fetchSequenceVolumeById(id);

  @override
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByBookId(String bookId) =>
      remoteDataSource.fetchSequenceVolumesByBookId(bookId);

  @override
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByWorkId(String workId) =>
      remoteDataSource.fetchSequenceVolumesByWorkId(workId);

  @override
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(String sequenceId) =>
      remoteDataSource.watchSequenceVolumes(sequenceId);

  @override
  Future<void> addSequenceVolume(SequenceVolumeEntity volume) async {
    await remoteDataSource.addSequenceVolume(
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

    await relationshipSyncService.syncSequenceVolumeRelationships(
      volumeId: volume.id,
      newSequenceId: volume.sequenceId,
      newBookId: volume.bookId,
      newWorkId: volume.workId,
    );
  }

  @override
  Future<void> editSequenceVolume(SequenceVolumeEntity volume) async {
    final SequenceVolumeModel? existingVolume = await remoteDataSource.fetchSequenceVolumeById(
      volume.id,
    );

    await remoteDataSource.editSequenceVolume(
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

    await relationshipSyncService.syncSequenceVolumeRelationships(
      volumeId: volume.id,
      newSequenceId: volume.sequenceId,
      newBookId: volume.bookId,
      newWorkId: volume.workId,
      oldSequenceId: existingVolume?.sequenceId,
      oldBookId: existingVolume?.bookId,
      oldWorkId: existingVolume?.workId,
    );
  }

  @override
  Future<void> removeSequenceVolume(String id) async {
    final SequenceVolumeModel? existingVolume = await remoteDataSource.fetchSequenceVolumeById(id);

    if (existingVolume != null) {
      await relationshipSyncService.removeSequenceVolumeRelationships(
        volumeId: id,
        sequenceId: existingVolume.sequenceId,
        bookId: existingVolume.bookId,
        workId: existingVolume.workId,
      );
    }

    await remoteDataSource.removeSequenceVolume(id);
  }
}
