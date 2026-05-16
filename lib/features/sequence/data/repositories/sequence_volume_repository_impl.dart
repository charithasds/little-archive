import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_volume_repository.dart';
import '../datasources/sequence_volume_remote_datasource.dart';
import '../models/sequence_volume_model.dart';

part 'sequence_volume_repository_impl.g.dart';

class SequenceVolumeRepositoryImpl implements SequenceVolumeRepository {
  SequenceVolumeRepositoryImpl({
    required this.remoteDataSource,
    required this.relationshipSyncService,
  });

  final SequenceVolumeRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

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
  Future<void> addSequenceVolume(SequenceVolumeEntity volume, {WriteBatch? batch}) async {
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
      batch: batch,
    );

    await relationshipSyncService.syncSequenceVolumeRelationships(
      volumeId: volume.id,
      newSequenceId: volume.sequenceId,
      newBookId: volume.bookId,
      newWorkId: volume.workId,
      batch: batch,
    );
  }

  @override
  Future<void> editSequenceVolume(SequenceVolumeEntity volume, {WriteBatch? batch}) async {
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
      batch: batch,
    );

    await relationshipSyncService.syncSequenceVolumeRelationships(
      volumeId: volume.id,
      newSequenceId: volume.sequenceId,
      newBookId: volume.bookId,
      newWorkId: volume.workId,
      oldSequenceId: existingVolume?.sequenceId,
      oldBookId: existingVolume?.bookId,
      oldWorkId: existingVolume?.workId,
      batch: batch,
    );
  }

  @override
  Future<void> removeSequenceVolume(String id, {WriteBatch? batch}) async {
    final SequenceVolumeModel? existingVolume = await remoteDataSource.fetchSequenceVolumeById(id);

    if (existingVolume != null) {
      await relationshipSyncService.removeSequenceVolumeRelationships(
        volumeId: id,
        sequenceId: existingVolume.sequenceId,
        bookId: existingVolume.bookId,
        workId: existingVolume.workId,
        batch: batch,
      );
    }

    await remoteDataSource.removeSequenceVolume(id, batch: batch);
  }

  @override
  Future<List<String>> syncBookVolumes(
    String bookId,
    Map<String, String> sequenceIdToVolume,
    bool isEdit, {
    WriteBatch? batch,
  }) async {
    if (isEdit) {
      final List<SequenceVolumeEntity> oldVolumes = await fetchSequenceVolumesByBookId(bookId);

      for (final SequenceVolumeEntity vol in oldVolumes) {
        await removeSequenceVolume(vol.id, batch: batch);
      }
    }

    final List<String> volumeIds = <String>[];

    for (final MapEntry<String, String> entry in sequenceIdToVolume.entries) {
      final String id = generateId();

      await addSequenceVolume(
        SequenceVolumeEntity(
          id: id,
          volume: entry.value,
          sequenceId: entry.key,
          bookId: bookId,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
        batch: batch,
      );

      volumeIds.add(id);
    }

    return volumeIds;
  }

  @override
  Future<List<String>> syncWorkVolumes(
    String workId,
    Map<String, String> sequenceIdToVolume,
    bool isEdit, {
    WriteBatch? batch,
  }) async {
    if (isEdit) {
      final List<SequenceVolumeEntity> oldVolumes = await fetchSequenceVolumesByWorkId(workId);

      for (final SequenceVolumeEntity vol in oldVolumes) {
        await removeSequenceVolume(vol.id, batch: batch);
      }
    }

    final List<String> volumeIds = <String>[];

    for (final MapEntry<String, String> entry in sequenceIdToVolume.entries) {
      final String id = generateId();

      await addSequenceVolume(
        SequenceVolumeEntity(
          id: id,
          volume: entry.value,
          sequenceId: entry.key,
          workId: workId,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
        batch: batch,
      );

      volumeIds.add(id);
    }

    return volumeIds;
  }
}

@riverpod
SequenceVolumeRepository sequenceVolumeRepository(Ref ref) {
  final SequenceVolumeRemoteDataSource remoteDataSource = ref.watch(
    sequenceVolumeRemoteDataSourceProvider,
  );
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return SequenceVolumeRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
