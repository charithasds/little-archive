import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/domain/utils/string_extensions.dart';
import '../../../../core/shared/presentation/providers/firebase_provider.dart';
import '../../../sequence/data/repositories/sequence_volume_repository_impl.dart';
import '../../../sequence/domain/repositories/sequence_volume_repository.dart';
import '../../../work/data/repositories/work_repository_impl.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/domain/repositories/work_repository.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scan/scanned_book_entity.dart';
import '../../domain/entities/scan/scanned_name_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';
import '../models/book_model.dart';

part 'book_repository_impl.g.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.relationshipSyncService,
    required this.firestore,
    required this.sequenceVolumeRepository,
    required this.workRepository,
  });

  final BookRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;
  final FirebaseFirestore firestore;
  final SequenceVolumeRepository sequenceVolumeRepository;
  final WorkRepository workRepository;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<BookEntity>> fetchBooks() => remoteDataSource.fetchBooks();

  @override
  Future<BookEntity?> fetchBookById(String id) => remoteDataSource.fetchBookById(id);

  @override
  Stream<List<BookEntity>> watchBooks() => remoteDataSource.watchBooks();

  @override
  Future<void> addBook(BookEntity book, {WriteBatch? batch}) async {
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
        sequenceVolumeIds: book.sequenceVolumeIds,
        workIds: book.workIds,
        publisherId: book.publisherId,
        readerId: book.readerId,
        createdDate: book.createdDate,
        lastUpdated: book.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncBookRelationships(
      bookId: book.id,
      newAuthorIds: book.authorIds,
      newTranslatorIds: book.translatorIds,
      newSequenceVolumeIds: book.sequenceVolumeIds,
      newWorkIds: book.workIds,
      newPublisherId: book.publisherId,
      newReaderId: book.readerId,
      batch: batch,
    );
  }

  @override
  Future<void> editBook(BookEntity book, {WriteBatch? batch}) async {
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
        sequenceVolumeIds: book.sequenceVolumeIds,
        workIds: book.workIds,
        publisherId: book.publisherId,
        readerId: book.readerId,
        createdDate: book.createdDate,
        lastUpdated: book.lastUpdated,
      ),
      batch: batch,
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
      batch: batch,
    );
  }

  @override
  Future<void> removeBook(String id, {WriteBatch? batch}) async {
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
        batch: batch,
      );
    }

    await remoteDataSource.removeBook(id, batch: batch);
  }

  @override
  Future<BookEntity> upsertBook(
    BookEntity book,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
    bool applyToWorks, {
    WriteBatch? batch,
  }) async {
    final WriteBatch effectiveBatch = batch ?? firestore.batch();
    final List<String> sequenceVolumeIds = await sequenceVolumeRepository.syncBookVolumes(
      book.id,
      sequenceIdToVolume,
      isEdit,
      batch: effectiveBatch,
    );
    final BookEntity bookToSave = book.copyWith(sequenceVolumeIds: sequenceVolumeIds);

    if (isEdit) {
      await editBook(bookToSave, batch: effectiveBatch);
    } else {
      await addBook(bookToSave, batch: effectiveBatch);
    }

    if (applyToWorks && bookToSave.compilationType == CompilationType.multiple) {
      for (final String workId in bookToSave.workIds) {
        final WorkEntity? work = await workRepository.fetchWorkById(workId);

        if (work != null) {
          final WorkEntity updatedWork = work.copyWith(
            bookId: Nullable<String?>(bookToSave.id),
            isTranslation: bookToSave.isTranslation,
            authorIds: bookToSave.authorIds,
            translatorIds: bookToSave.translatorIds,
            language: Nullable<Language?>(bookToSave.language),
            originalLanguage: Nullable<OriginalLanguage?>(bookToSave.originalLanguage),
          );

          await workRepository.editWork(updatedWork, batch: effectiveBatch);
        }
      }
    }

    if (batch == null) {
      await effectiveBatch.commit();
    }

    return bookToSave;
  }

  @override
  Future<ScannedBookEntity> scanBookCover(Uint8List imageBytes) async {
    final Map<String, dynamic> data = await remoteDataSource.scanBookCover(imageBytes);
    final String title = data['title'] as String? ?? '';
    final bool isTranslation = data['isTranslation'] as bool? ?? false;
    final String? languageStr = data['language'] as String?;
    final Language? language;
    final String? originalTitle = data['originalTitle'] as String?;
    final String? originalLanguageStr = data['originalLanguage'] as String?;
    final OriginalLanguage? originalLanguage;
    final List<dynamic> authorsRaw = data['authorNames'] as List<dynamic>? ?? <dynamic>[];
    final List<ScannedNameEntity> authors = authorsRaw.map((dynamic e) {
      final Map<String, dynamic> map = e as Map<String, dynamic>;
      final String name = map['name'] as String? ?? '';
      final String? otherName = map['otherName'] as String?;

      return ScannedNameEntity(name: name.toTitleCase(), otherName: otherName?.toTitleCase());
    }).toList();
    final List<dynamic> translatorsRaw = data['translatorNames'] as List<dynamic>? ?? <dynamic>[];
    final List<ScannedNameEntity> translators = translatorsRaw.map((dynamic e) {
      final Map<String, dynamic> map = e as Map<String, dynamic>;
      final String name = map['name'] as String? ?? '';
      final String? otherName = map['otherName'] as String?;

      return ScannedNameEntity(name: name.toTitleCase(), otherName: otherName?.toTitleCase());
    }).toList();
    final dynamic publisherRaw = data['publisher'];
    final ScannedNameEntity? publisher;
    final String? isbn = (data['isbn'] as String?).cleanDummyData;
    BookEntity bookEntity;

    if (languageStr != null) {
      language = Language.values.where((Language e) => e.name == languageStr).firstOrNull;
    } else {
      language = null;
    }

    if (originalLanguageStr != null) {
      originalLanguage = OriginalLanguage.values
          .where((OriginalLanguage e) => e.name == originalLanguageStr)
          .firstOrNull;
    } else {
      originalLanguage = null;
    }

    bookEntity = BookEntity(
      id: '',
      title: title,
      compilationType: CompilationType.single,
      isTranslation: isTranslation,
      language: language,
      originalTitle: originalTitle,
      originalLanguage: originalLanguage,
      collectionStatus: CollectionStatus.collected,
      readingStatus: ReadingStatus.notStarted,
      isbn: isbn,
      authorIds: const <String>[],
      translatorIds: const <String>[],
      workIds: const <String>[],
      sequenceVolumeIds: const <String>[],
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    if (publisherRaw != null && publisherRaw is Map<String, dynamic>) {
      final String name = publisherRaw['name'] as String? ?? '';
      final String? otherName = publisherRaw['otherName'] as String?;

      publisher = ScannedNameEntity(name: name.toTitleCase(), otherName: otherName?.toTitleCase());
    } else {
      publisher = null;
    }

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
  final FirebaseFirestore firestore = ref.watch(firebaseFirestoreProvider);
  final SequenceVolumeRepository sequenceVolumeRepository = ref.watch(
    sequenceVolumeRepositoryProvider,
  );
  final WorkRepository workRepository = ref.watch(workRepositoryProvider);

  return BookRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
    firestore: firestore,
    sequenceVolumeRepository: sequenceVolumeRepository,
    workRepository: workRepository,
  );
}
