import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../datasources/work_remote_datasource.dart';
import '../models/work_model.dart';

class WorkRepositoryImpl implements WorkRepository {
  WorkRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});
  final WorkRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<WorkEntity>> getWorks() => remoteDataSource.fetchWorks();

  @override
  Future<WorkEntity?> getWorkById(String id) => remoteDataSource.fetchWorkById(id);

  @override
  Stream<List<WorkEntity>> watchWorks() => remoteDataSource.watchWorks();

  @override
  Future<void> addWork(WorkEntity work) async {
    await remoteDataSource.addWork(
      WorkModel(
        id: work.id,
        title: work.title,
        contentCategory: work.contentCategory,
        language: work.language,
        genre: work.genre,
        noOfPages: work.noOfPages,
        isTranslation: work.isTranslation,
        originalTitle: work.originalTitle,
        originalLanguage: work.originalLanguage,
        readingStatus: work.readingStatus,
        pausedPage: work.pausedPage,
        completedDate: work.completedDate,
        notes: work.notes,
        createdDate: work.createdDate,
        lastUpdated: work.lastUpdated,
        authorIds: work.authorIds,
        translatorIds: work.translatorIds,
        sequenceVolumeIds: work.sequenceVolumeIds,
        bookId: work.bookId,
      ),
    );

    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
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
        language: work.language,
        genre: work.genre,
        noOfPages: work.noOfPages,
        isTranslation: work.isTranslation,
        originalTitle: work.originalTitle,
        originalLanguage: work.originalLanguage,
        readingStatus: work.readingStatus,
        pausedPage: work.pausedPage,
        completedDate: work.completedDate,
        notes: work.notes,
        createdDate: work.createdDate,
        lastUpdated: work.lastUpdated,
        authorIds: work.authorIds,
        translatorIds: work.translatorIds,
        sequenceVolumeIds: work.sequenceVolumeIds,
        bookId: work.bookId,
      ),
    );

    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
      oldAuthorIds: existingWork?.authorIds ?? <String>[],
      oldTranslatorIds: existingWork?.translatorIds ?? <String>[],
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
      );
    }

    await remoteDataSource.removeWork(id);
  }
}
