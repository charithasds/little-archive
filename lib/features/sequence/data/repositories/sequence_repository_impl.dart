import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../datasources/sequence_remote_datasource.dart';
import '../models/sequence_model.dart';

part 'sequence_repository_impl.g.dart';

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
  Future<void> addSequence(SequenceEntity sequence, {WriteBatch? batch}) async {
    await remoteDataSource.addSequence(
      SequenceModel(
        id: sequence.id,
        name: sequence.name,
        notes: sequence.notes,
        sequenceVolumeIds: sequence.sequenceVolumeIds,
        createdDate: sequence.createdDate,
        lastUpdated: sequence.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncSequenceRelationships(
      sequenceId: sequence.id,
      newSequenceVolumeIds: sequence.sequenceVolumeIds,
      batch: batch,
    );
  }

  @override
  Future<void> editSequence(SequenceEntity sequence, {SequenceEntity? oldSequence, WriteBatch? batch}) async {
    final List<String> oldSequenceVolumeIds;

    if (oldSequence != null) {
      oldSequenceVolumeIds = oldSequence.sequenceVolumeIds;
    } else {
      final SequenceModel? existingSequence = await remoteDataSource.fetchSequenceById(sequence.id);
      oldSequenceVolumeIds = existingSequence?.sequenceVolumeIds ?? <String>[];
    }

    await remoteDataSource.editSequence(
      SequenceModel(
        id: sequence.id,
        name: sequence.name,
        notes: sequence.notes,
        sequenceVolumeIds: sequence.sequenceVolumeIds,
        createdDate: sequence.createdDate,
        lastUpdated: sequence.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncSequenceRelationships(
      sequenceId: sequence.id,
      newSequenceVolumeIds: sequence.sequenceVolumeIds,
      oldSequenceVolumeIds: oldSequenceVolumeIds,
      batch: batch,
    );
  }

  @override
  Future<void> removeSequence(String id, {WriteBatch? batch}) async {
    final SequenceModel? existingSequence = await remoteDataSource.fetchSequenceById(id);

    if (existingSequence != null) {
      await relationshipSyncService.removeSequenceRelationships(
        sequenceId: id,
        sequenceVolumeIds: existingSequence.sequenceVolumeIds,
        batch: batch,
      );
    }

    await remoteDataSource.removeSequence(id, batch: batch);
  }
}

@riverpod
SequenceRepository sequenceRepository(Ref ref) {
  final SequenceRemoteDataSource remoteDataSource = ref.watch(sequenceRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return SequenceRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
