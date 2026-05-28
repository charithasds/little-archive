import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/providers/firebase_provider.dart';
import '../../../sequence/data/repositories/sequence_volume_repository_impl.dart';
import '../../../sequence/domain/repositories/sequence_volume_repository.dart';
import '../../../work/data/repositories/work_repository_impl.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/domain/repositories/work_repository.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scan/scanned_book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';
import '../models/book_model.dart';
import '../models/scanned_book_model.dart';

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
        toBeTranslated: book.toBeTranslated,
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
  Future<void> editBook(BookEntity book, {BookEntity? oldBook, WriteBatch? batch}) async {
    final List<String> oldAuthorIds;
    final List<String> oldTranslatorIds;
    final List<String> oldSequenceVolumeIds;
    final List<String> oldWorkIds;
    final String? oldPublisherId;
    final String? oldReaderId;

    if (oldBook != null) {
      oldAuthorIds = oldBook.authorIds;
      oldTranslatorIds = oldBook.translatorIds;
      oldSequenceVolumeIds = oldBook.sequenceVolumeIds;
      oldWorkIds = oldBook.workIds;
      oldPublisherId = oldBook.publisherId;
      oldReaderId = oldBook.readerId;
    } else {
      final BookModel? existingBook = await remoteDataSource.fetchBookById(book.id);
      oldAuthorIds = existingBook?.authorIds ?? <String>[];
      oldTranslatorIds = existingBook?.translatorIds ?? <String>[];
      oldSequenceVolumeIds = existingBook?.sequenceVolumeIds ?? <String>[];
      oldWorkIds = existingBook?.workIds ?? <String>[];
      oldPublisherId = existingBook?.publisherId;
      oldReaderId = existingBook?.readerId;
    }

    await remoteDataSource.editBook(
      BookModel(
        id: book.id,
        title: book.title,
        compilationType: book.compilationType,
        isTranslation: book.isTranslation,
        toBeTranslated: book.toBeTranslated,
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
      oldAuthorIds: oldAuthorIds,
      oldTranslatorIds: oldTranslatorIds,
      oldSequenceVolumeIds: oldSequenceVolumeIds,
      oldWorkIds: oldWorkIds,
      oldPublisherId: oldPublisherId,
      oldReaderId: oldReaderId,
      batch: batch,
    );
  }

  @override
  Future<void> removeBook(String id, {WriteBatch? batch}) async {
    final BookModel? existingBook = await remoteDataSource.fetchBookById(id);

    if (existingBook != null) {
      final WriteBatch effectiveBatch = batch ?? firestore.batch();

      for (final String volumeId in existingBook.sequenceVolumeIds) {
        await sequenceVolumeRepository.removeSequenceVolume(volumeId, batch: effectiveBatch);
      }

      await relationshipSyncService.removeBookRelationships(
        bookId: id,
        authorIds: existingBook.authorIds,
        translatorIds: existingBook.translatorIds,
        sequenceVolumeIds: existingBook.sequenceVolumeIds,
        workIds: existingBook.workIds,
        publisherId: existingBook.publisherId,
        readerId: existingBook.readerId,
        batch: effectiveBatch,
      );

      await remoteDataSource.removeBook(id, batch: effectiveBatch);

      if (batch == null) {
        await effectiveBatch.commit();
      }
    }
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

    return ScannedBookModel.fromMap(data);
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
