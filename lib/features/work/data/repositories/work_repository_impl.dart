import '../../../../core/services/relationship_sync_service.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../datasources/work_remote_datasource.dart';
import '../models/work_model.dart';

class WorkRepositoryImpl implements WorkRepository {

  WorkRepositoryImpl({
    required this.remoteDataSource,
    required this.relationshipSyncService,
  });
  final WorkRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  Future<List<WorkEntity>> getWorks(String userId) =>
      remoteDataSource.getWorks(userId);

  @override
  Future<WorkEntity?> getWorkById(String id) =>
      remoteDataSource.getWorkById(id);

  @override
  Future<void> addWork(WorkEntity work) async {
    // First, add the work to the database
    await remoteDataSource.addWork(
      WorkModel(
        id: work.id,
        userId: work.userId,
        title: work.title,
        language: work.language,
        genre: work.genre,
        workType: work.workType,
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
        sequenceVolumeId: work.sequenceVolumeId,
        bookId: work.bookId,
      ),
    );

    // Then, sync the relationships (add workId to related entities)
    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
    );
  }

  @override
  Future<void> updateWork(WorkEntity work) async {
    // First, get the existing work to compare relationships
    final WorkModel? existingWork = await remoteDataSource.getWorkById(work.id);

    // Update the work in the database
    await remoteDataSource.updateWork(
      WorkModel(
        id: work.id,
        userId: work.userId,
        title: work.title,
        language: work.language,
        genre: work.genre,
        workType: work.workType,
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
        sequenceVolumeId: work.sequenceVolumeId,
        bookId: work.bookId,
      ),
    );

    // Sync relationships, comparing old and new values
    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
      oldAuthorIds: existingWork?.authorIds ?? <String>[],
      oldTranslatorIds: existingWork?.translatorIds ?? <String>[],
    );
  }

  @override
  Future<void> deleteWork(String id) async {
    // First, get the existing work to know which relationships to remove
    final WorkModel? existingWork = await remoteDataSource.getWorkById(id);

    if (existingWork != null) {
      // Remove relationships from related entities
      await relationshipSyncService.removeWorkRelationships(
        workId: id,
        authorIds: existingWork.authorIds,
        translatorIds: existingWork.translatorIds,
      );
    }

    // Then delete the work
    await remoteDataSource.deleteWork(id);
  }

  @override
  Stream<List<WorkEntity>> watchWorks(String userId) =>
      remoteDataSource.watchWorks(userId);
}
