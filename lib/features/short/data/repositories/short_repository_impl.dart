import '../datasources/short_remote_datasource.dart';
import '../../domain/entities/short_entity.dart';
import '../../domain/repositories/short_repository.dart';
import '../models/short_model.dart';

class ShortRepositoryImpl implements ShortRepository {
  final ShortRemoteDataSource remoteDataSource;

  ShortRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ShortEntity>> getShorts() => remoteDataSource.getShorts();

  @override
  Future<ShortEntity?> getShortById(String id) =>
      remoteDataSource.getShortById(id);

  @override
  Future<void> addShort(ShortEntity short) {
    return remoteDataSource.addShort(
      ShortModel(
        id: short.id,
        title: short.title,
        language: short.language,
        genre: short.genre,
        noOfPages: short.noOfPages,
        isTranslation: short.isTranslation,
        originalTitle: short.originalTitle,
        originalLanguage: short.originalLanguage,
        readingStatus: short.readingStatus,
        pausedPage: short.pausedPage,
        completedDate: short.completedDate,
        notes: short.notes,
        createdDate: short.createdDate,
        lastUpdated: short.lastUpdated,
        authorIds: short.authorIds,
        translatorIds: short.translatorIds,
        sequenceVolumeId: short.sequenceVolumeId,
        bookId: short.bookId,
      ),
    );
  }

  @override
  Future<void> updateShort(ShortEntity short) {
    return remoteDataSource.updateShort(
      ShortModel(
        id: short.id,
        title: short.title,
        language: short.language,
        genre: short.genre,
        noOfPages: short.noOfPages,
        isTranslation: short.isTranslation,
        originalTitle: short.originalTitle,
        originalLanguage: short.originalLanguage,
        readingStatus: short.readingStatus,
        pausedPage: short.pausedPage,
        completedDate: short.completedDate,
        notes: short.notes,
        createdDate: short.createdDate,
        lastUpdated: short.lastUpdated,
        authorIds: short.authorIds,
        translatorIds: short.translatorIds,
        sequenceVolumeId: short.sequenceVolumeId,
        bookId: short.bookId,
      ),
    );
  }

  @override
  Future<void> deleteShort(String id) => remoteDataSource.deleteShort(id);

  @override
  Stream<List<ShortEntity>> watchShorts() => remoteDataSource.watchShorts();
}
