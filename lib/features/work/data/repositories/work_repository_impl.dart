import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../datasources/work_remote_datasource.dart';
import '../models/work_model.dart';

part 'work_repository_impl.g.dart';

class WorkRepositoryImpl implements WorkRepository {
  WorkRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});

  final WorkRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<WorkEntity>> fetchWorks() => remoteDataSource.fetchWorks();

  @override
  Future<WorkEntity?> fetchWorkById(String id) => remoteDataSource.fetchWorkById(id);

  @override
  Stream<List<WorkEntity>> watchWorks() => remoteDataSource.watchWorks();

  @override
  Future<void> addWork(WorkEntity work) async {
    await remoteDataSource.addWork(
      WorkModel(
        id: work.id,
        title: work.title,
        contentCategory: work.contentCategory,
        isTranslation: work.isTranslation,
        language: work.language,
        genre: work.genre,
        originalTitle: work.originalTitle,
        originalLanguage: work.originalLanguage,
        notes: work.notes,
        authorIds: work.authorIds,
        translatorIds: work.translatorIds,
        sequenceVolumeIds: work.sequenceVolumeIds,
        bookId: work.bookId,
        createdDate: work.createdDate,
        lastUpdated: work.lastUpdated,
      ),
    );

    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
      newSequenceVolumeIds: work.sequenceVolumeIds,
      newBookId: work.bookId,
    );
  }

  @override
  Future<void> editWork(WorkEntity work) async {
    final WorkModel? existingWork = await remoteDataSource.fetchWorkById(work.id);

    await remoteDataSource.editWork(
      WorkModel(
        id: work.id,
        title: work.title,
        contentCategory: work.contentCategory,
        isTranslation: work.isTranslation,
        language: work.language,
        genre: work.genre,
        originalTitle: work.originalTitle,
        originalLanguage: work.originalLanguage,
        notes: work.notes,
        authorIds: work.authorIds,
        translatorIds: work.translatorIds,
        sequenceVolumeIds: work.sequenceVolumeIds,
        bookId: work.bookId,
        createdDate: work.createdDate,
        lastUpdated: work.lastUpdated,
      ),
    );

    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
      newSequenceVolumeIds: work.sequenceVolumeIds,
      newBookId: work.bookId,
      oldAuthorIds: existingWork?.authorIds ?? <String>[],
      oldTranslatorIds: existingWork?.translatorIds ?? <String>[],
      oldSequenceVolumeIds: existingWork?.sequenceVolumeIds ?? <String>[],
      oldBookId: existingWork?.bookId,
    );
  }

  @override
  Future<void> removeWork(String id) async {
    final WorkModel? existingWork = await remoteDataSource.fetchWorkById(id);

    if (existingWork != null) {
      await relationshipSyncService.removeWorkRelationships(
        workId: id,
        authorIds: existingWork.authorIds,
        translatorIds: existingWork.translatorIds,
        sequenceVolumeIds: existingWork.sequenceVolumeIds,
        bookId: existingWork.bookId,
      );
    }

    await remoteDataSource.removeWork(id);
  }

  @override
  Future<int> fetchCount() => remoteDataSource.fetchCount();
}

@riverpod
WorkRepository workRepository(Ref ref) {
  final WorkRemoteDataSource remoteDataSource = ref.watch(workRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return WorkRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
