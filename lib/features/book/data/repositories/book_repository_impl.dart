import '../datasources/book_remote_datasource.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BookEntity>> getBooks(String userId) =>
      remoteDataSource.getBooks(userId);

  @override
  Future<BookEntity?> getBookById(String id) =>
      remoteDataSource.getBookById(id);

  @override
  Future<void> addBook(BookEntity book) {
    return remoteDataSource.addBook(
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
  }

  @override
  Future<void> updateBook(BookEntity book) {
    return remoteDataSource.updateBook(
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
  }

  @override
  Future<void> deleteBook(String id) => remoteDataSource.deleteBook(id);

  @override
  Stream<List<BookEntity>> watchBooks(String userId) =>
      remoteDataSource.watchBooks(userId);
}
