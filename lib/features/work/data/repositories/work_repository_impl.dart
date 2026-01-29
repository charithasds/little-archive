import '../datasources/work_remote_datasource.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../models/work_model.dart';

class WorkRepositoryImpl implements WorkRepository {
  final WorkRemoteDataSource remoteDataSource;

  WorkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<WorkEntity>> getWorks(String userId) =>
      remoteDataSource.getWorks(userId);

  @override
  Future<WorkEntity?> getWorkById(String id) =>
      remoteDataSource.getWorkById(id);

  @override
  Future<void> addWork(WorkEntity work) {
    return remoteDataSource.addWork(
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
  }

  @override
  Future<void> updateWork(WorkEntity work) {
    return remoteDataSource.updateWork(
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
  }

  @override
  Future<void> deleteWork(String id) => remoteDataSource.deleteWork(id);

  @override
  Stream<List<WorkEntity>> watchWorks(String userId) =>
      remoteDataSource.watchWorks(userId);
}
