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
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<BookEntity>> fetchBooks() => remoteDataSource.fetchBooks();

  @override
  Future<BookEntity?> fetchBookById(String id) => remoteDataSource.fetchBookById(id);

  @override
  Stream<List<BookEntity>> watchBooks() => remoteDataSource.watchBooks();

  @override
  Future<void> addBook(BookEntity book) async {
    await remoteDataSource.addBook(
      BookModel(
        id: book.id,
        title: book.title,
        compilationType: book.compilationType,
        isTranslation: book.isTranslation,
        cover: book.cover,
        language: book.language,
        genre: book.genre,
        isbn: book.isbn,
        publishedDate: book.publishedDate,
        noOfPages: book.noOfPages,
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
        authorIds: book.authorIds,
        translatorIds: book.translatorIds,
        workIds: book.workIds,
        sequenceVolumeIds: book.sequenceVolumeIds,
        publisherId: book.publisherId,
        readerId: book.readerId,
        createdDate: book.createdDate,
        lastUpdated: book.lastUpdated,
      ),
    );

    await relationshipSyncService.syncBookRelationships(
      bookId: book.id,
      newAuthorIds: book.authorIds,
      newTranslatorIds: book.translatorIds,
      newSequenceVolumeIds: book.sequenceVolumeIds,
      newPublisherId: book.publisherId,
      newReaderId: book.readerId,
    );
  }

  @override
  Future<void> editBook(BookEntity book) async {
    final BookModel? existingBook = await remoteDataSource.fetchBookById(book.id);

    await remoteDataSource.editBook(
      BookModel(
        id: book.id,
        title: book.title,
        compilationType: book.compilationType,
        isTranslation: book.isTranslation,
        cover: book.cover,
        language: book.language,
        genre: book.genre,
        isbn: book.isbn,
        publishedDate: book.publishedDate,
        noOfPages: book.noOfPages,
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
        authorIds: book.authorIds,
        translatorIds: book.translatorIds,
        workIds: book.workIds,
        sequenceVolumeIds: book.sequenceVolumeIds,
        publisherId: book.publisherId,
        readerId: book.readerId,
        createdDate: book.createdDate,
        lastUpdated: book.lastUpdated,
      ),
    );

    await relationshipSyncService.syncBookRelationships(
      bookId: book.id,
      newAuthorIds: book.authorIds,
      newTranslatorIds: book.translatorIds,
      newSequenceVolumeIds: book.sequenceVolumeIds,
      newPublisherId: book.publisherId,
      newReaderId: book.readerId,
      oldAuthorIds: existingBook?.authorIds ?? <String>[],
      oldTranslatorIds: existingBook?.translatorIds ?? <String>[],
      oldSequenceVolumeIds: existingBook?.sequenceVolumeIds ?? <String>[],
      oldPublisherId: existingBook?.publisherId,
      oldReaderId: existingBook?.readerId,
    );
  }

  @override
  Future<void> removeBook(String id) async {
    final BookModel? existingBook = await remoteDataSource.fetchBookById(id);

    if (existingBook != null) {
      await relationshipSyncService.removeBookRelationships(
        bookId: id,
        authorIds: existingBook.authorIds,
        translatorIds: existingBook.translatorIds,
        sequenceVolumeIds: existingBook.sequenceVolumeIds,
        publisherId: existingBook.publisherId,
        readerId: existingBook.readerId,
      );
    }

    await remoteDataSource.removeBook(id);
  }
}
