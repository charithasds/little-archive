import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
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
    required this.sequenceVolumeRepository,
    required this.workRepository,
  });

  final BookRemoteDataSource remoteDataSource;
  final SequenceVolumeRepository sequenceVolumeRepository;
  final WorkRepository workRepository;

  final Set<String> _processedCoverBookIds = <String>{};

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<BookEntity>> fetchBooks() async {
    final List<BookEntity> books = await remoteDataSource.fetchBooks();
    _compressExistingLargeCovers(books);
    return books;
  }

  void _compressExistingLargeCovers(List<BookEntity> books) {
    Future<void>.microtask(() async {
      for (final BookEntity book in books) {
        if (_processedCoverBookIds.contains(book.id)) {
          continue;
        }
        _processedCoverBookIds.add(book.id);

        final String? cover = book.cover;
        if (cover != null && cover.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(cover);
          if (compressed != null && compressed != cover) {
            final BookEntity updated = book.copyWith(
              cover: Nullable<String?>(compressed),
              lastUpdated: DateTime.now(),
            );
            await editBook(updated);
          }
        }
      }
    });
  }

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
    );
  }

  @override
  Future<void> editBook(BookEntity book, {BookEntity? oldBook}) async {
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
    );
  }

  @override
  Future<void> removeBook(String id) async {
    final BookModel? existingBook = await remoteDataSource.fetchBookById(id);

    if (existingBook != null) {
      for (final String volumeId in existingBook.sequenceVolumeIds) {
        await sequenceVolumeRepository.removeSequenceVolume(volumeId);
      }

      await remoteDataSource.removeBook(id);
    }
  }

  @override
  Future<BookEntity> upsertBook(
    BookEntity book,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
    bool applyToWorks,
  ) async {
    final List<String> sequenceVolumeIds = await sequenceVolumeRepository.syncBookVolumes(
      book.id,
      sequenceIdToVolume,
      isEdit,
    );
    final BookEntity bookToSave = book.copyWith(sequenceVolumeIds: sequenceVolumeIds);

    if (isEdit) {
      await editBook(bookToSave);
    } else {
      await addBook(bookToSave);
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

          await workRepository.editWork(updatedWork);
        }
      }
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
  final SequenceVolumeRepository sequenceVolumeRepository = ref.watch(
    sequenceVolumeRepositoryProvider,
  );
  final WorkRepository workRepository = ref.watch(workRepositoryProvider);

  return BookRepositoryImpl(
    remoteDataSource: remoteDataSource,
    sequenceVolumeRepository: sequenceVolumeRepository,
    workRepository: workRepository,
  );
}
