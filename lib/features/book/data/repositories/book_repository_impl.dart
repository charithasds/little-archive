import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scanned_book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';
import '../models/book_model.dart';

part 'book_repository_impl.g.dart';

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
        language: book.language,
        originalTitle: book.originalTitle,
        originalLanguage: book.originalLanguage,
        publishedDate: book.publishedDate,
        noOfPages: book.noOfPages,
        isbn: book.isbn,
        genre: book.genre,
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
        cover: book.cover,
      ),
    );

    await relationshipSyncService.syncBookRelationships(
      bookId: book.id,
      newAuthorIds: book.authorIds,
      newTranslatorIds: book.translatorIds,
      newSequenceVolumeIds: book.sequenceVolumeIds,
      newWorkIds: book.workIds,
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
        language: book.language,
        originalTitle: book.originalTitle,
        originalLanguage: book.originalLanguage,
        publishedDate: book.publishedDate,
        noOfPages: book.noOfPages,
        isbn: book.isbn,
        genre: book.genre,
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
        cover: book.cover,
      ),
    );

    await relationshipSyncService.syncBookRelationships(
      bookId: book.id,
      newAuthorIds: book.authorIds,
      newTranslatorIds: book.translatorIds,
      newSequenceVolumeIds: book.sequenceVolumeIds,
      newWorkIds: book.workIds,
      newPublisherId: book.publisherId,
      newReaderId: book.readerId,
      oldAuthorIds: existingBook?.authorIds ?? <String>[],
      oldTranslatorIds: existingBook?.translatorIds ?? <String>[],
      oldSequenceVolumeIds: existingBook?.sequenceVolumeIds ?? <String>[],
      oldWorkIds: existingBook?.workIds ?? <String>[],
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
        workIds: existingBook.workIds,
        publisherId: existingBook.publisherId,
        readerId: existingBook.readerId,
      );
    }

    await remoteDataSource.removeBook(id);
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text
        .split(RegExp(r'\s+'))
        .map((String word) {
          if (word.isEmpty) {
            return word;
          }
          if (word.length == 1) {
            return word.toUpperCase();
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String? _cleanDummyData(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    final String upper = trimmed.toUpperCase();
    if (upper == 'N/A' ||
        upper == 'NA' ||
        upper == 'UNKNOWN' ||
        upper == 'NONE' ||
        trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  @override
  Future<ScannedBookEntity> scanBookCover(Uint8List imageBytes) async {
    final Map<String, dynamic> data = await remoteDataSource.scanBookCover(imageBytes);

    final String title = data['title'] as String? ?? '';
    final bool isTranslation = data['isTranslation'] as bool? ?? false;
    final String? languageStr = data['language'] as String?;
    final String? originalTitle = data['originalTitle'] as String?;
    final String? originalLanguageStr = data['originalLanguage'] as String?;

    final List<dynamic> authorsRaw = data['authorNames'] as List<dynamic>? ?? <dynamic>[];
    final List<ScannedNameEntity> authors = authorsRaw.map((dynamic e) {
      final Map<String, dynamic> m = e as Map<String, dynamic>;
      final String name = m['name'] as String? ?? '';
      final String? otherName = m['otherName'] as String?;
      return ScannedNameEntity(
        name: _toTitleCase(name),
        otherName: otherName != null ? _toTitleCase(otherName) : null,
      );
    }).toList();

    final List<dynamic> translatorsRaw = data['translatorNames'] as List<dynamic>? ?? <dynamic>[];
    final List<ScannedNameEntity> translators = translatorsRaw.map((dynamic e) {
      final Map<String, dynamic> m = e as Map<String, dynamic>;
      final String name = m['name'] as String? ?? '';
      final String? otherName = m['otherName'] as String?;
      return ScannedNameEntity(
        name: _toTitleCase(name),
        otherName: otherName != null ? _toTitleCase(otherName) : null,
      );
    }).toList();

    ScannedNameEntity? publisher;
    final dynamic publisherRaw = data['publisher'];
    if (publisherRaw != null && publisherRaw is Map<String, dynamic>) {
      final String name = publisherRaw['name'] as String? ?? '';
      final String? otherName = publisherRaw['otherName'] as String?;
      publisher = ScannedNameEntity(
        name: _toTitleCase(name),
        otherName: otherName != null ? _toTitleCase(otherName) : null,
      );
    }

    final String? isbn = _cleanDummyData(data['isbn'] as String?);
    final String? genreStr = data['genre'] as String?;

    Language? language;
    if (languageStr != null) {
      language = Language.values.where((Language e) => e.name == languageStr).firstOrNull;
    }

    OriginalLanguage? originalLanguage;
    if (originalLanguageStr != null) {
      originalLanguage = OriginalLanguage.values
          .where((OriginalLanguage e) => e.name == originalLanguageStr)
          .firstOrNull;
    }

    Genre? genre;
    if (genreStr != null) {
      genre = Genre.values.where((Genre e) => e.name == genreStr).firstOrNull;
    }

    final BookEntity bookEntity = BookEntity(
      id: '',
      title: title,
      compilationType: CompilationType.standalone,
      isTranslation: isTranslation,
      language: language,
      originalTitle: originalTitle,
      originalLanguage: originalLanguage,
      isbn: isbn,
      genre: genre,
      authorIds: const <String>[],
      translatorIds: const <String>[],
      workIds: const <String>[],
      sequenceVolumeIds: const <String>[],
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    return ScannedBookEntity(
      book: bookEntity,
      authors: authors,
      translators: translators,
      publisher: publisher,
      analysisError: data['analysisError'] as String?,
    );
  }
}

@riverpod
BookRepository bookRepository(Ref ref) {
  final BookRemoteDataSource remoteDataSource = ref.watch(bookRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return BookRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
