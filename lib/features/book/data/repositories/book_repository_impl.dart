import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});
  final BookRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  Future<List<BookEntity>> getBooks(String userId) => remoteDataSource.getBooks(userId);

  @override
  Future<BookEntity?> getBookById(String id) => remoteDataSource.getBookById(id);

  @override
  Future<void> addBook(BookEntity book) async {
    await remoteDataSource.addBook(
      BookModel(
        id: book.id,
        userId: book.userId,
        title: book.title,
        cover: book.cover,
        compilationType: book.compilationType,
        language: book.language,
        genre: book.genre,
        isbn: book.isbn,
        publishedDate: book.publishedDate,
        noOfPages: book.noOfPages,
        isTranslation: book.isTranslation,
        originalTitle: book.originalTitle,
        originalLanguage: book.originalLanguage,
        collectionStatus: book.collectionStatus,
        collectedDate: book.collectedDate,
        lendedDate: book.lendedDate,
        dueDate: book.dueDate,
        readingStatus: book.readingStatus,
        pausedPage: book.pausedPage,
        completedDate: book.completedDate,
        notes: book.notes,
        createdDate: book.createdDate,
        lastUpdated: book.lastUpdated,
        authorIds: book.authorIds,
        translatorIds: book.translatorIds,
        workIds: book.workIds,
        sequenceVolumeId: book.sequenceVolumeId,
        publisherId: book.publisherId,
        readerId: book.readerId,
      ),
    );

    await relationshipSyncService.syncBookRelationships(
      bookId: book.id,
      newAuthorIds: book.authorIds,
      newTranslatorIds: book.translatorIds,
      newPublisherId: book.publisherId,
      newReaderId: book.readerId,
    );
  }

  @override
  Future<void> updateBook(BookEntity book) async {
    final BookModel? existingBook = await remoteDataSource.getBookById(book.id);

    await remoteDataSource.updateBook(
      BookModel(
        id: book.id,
        userId: book.userId,
        title: book.title,
        cover: book.cover,
        compilationType: book.compilationType,
        language: book.language,
        genre: book.genre,
        isbn: book.isbn,
        publishedDate: book.publishedDate,
        noOfPages: book.noOfPages,
        isTranslation: book.isTranslation,
        originalTitle: book.originalTitle,
        originalLanguage: book.originalLanguage,
        collectionStatus: book.collectionStatus,
        collectedDate: book.collectedDate,
        lendedDate: book.lendedDate,
        dueDate: book.dueDate,
        readingStatus: book.readingStatus,
        pausedPage: book.pausedPage,
        completedDate: book.completedDate,
        notes: book.notes,
        createdDate: book.createdDate,
        lastUpdated: book.lastUpdated,
        authorIds: book.authorIds,
        translatorIds: book.translatorIds,
        workIds: book.workIds,
        sequenceVolumeId: book.sequenceVolumeId,
        publisherId: book.publisherId,
        readerId: book.readerId,
      ),
    );

    await relationshipSyncService.syncBookRelationships(
      bookId: book.id,
      newAuthorIds: book.authorIds,
      newTranslatorIds: book.translatorIds,
      newPublisherId: book.publisherId,
      newReaderId: book.readerId,
      oldAuthorIds: existingBook?.authorIds ?? <String>[],
      oldTranslatorIds: existingBook?.translatorIds ?? <String>[],
      oldPublisherId: existingBook?.publisherId,
      oldReaderId: existingBook?.readerId,
    );
  }

  @override
  Future<void> deleteBook(String id) async {
    final BookModel? existingBook = await remoteDataSource.getBookById(id);

    if (existingBook != null) {
      await relationshipSyncService.removeBookRelationships(
        bookId: id,
        authorIds: existingBook.authorIds,
        translatorIds: existingBook.translatorIds,
        publisherId: existingBook.publisherId,
        readerId: existingBook.readerId,
      );
    }

    await remoteDataSource.deleteBook(id);
  }

  @override
  Stream<List<BookEntity>> watchBooks(String userId) => remoteDataSource.watchBooks(userId);
}
