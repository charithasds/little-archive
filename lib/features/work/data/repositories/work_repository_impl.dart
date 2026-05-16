import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/providers/firebase_provider.dart';
import '../../../book/data/datasources/book_remote_datasource.dart';
import '../../../book/data/models/book_model.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../sequence/data/repositories/sequence_volume_repository_impl.dart';
import '../../../sequence/domain/repositories/sequence_volume_repository.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../datasources/work_remote_datasource.dart';
import '../models/work_model.dart';

part 'work_repository_impl.g.dart';

class WorkRepositoryImpl implements WorkRepository {
  WorkRepositoryImpl({
    required this.remoteDataSource,
    required this.relationshipSyncService,
    required this.firestore,
    required this.sequenceVolumeRepository,
    required this.bookRemoteDataSource,
  });

  final WorkRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;
  final FirebaseFirestore firestore;
  final SequenceVolumeRepository sequenceVolumeRepository;
  final BookRemoteDataSource bookRemoteDataSource;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<WorkEntity>> fetchWorks() => remoteDataSource.fetchWorks();

  @override
  Future<WorkEntity?> fetchWorkById(String id) => remoteDataSource.fetchWorkById(id);

  @override
  Stream<List<WorkEntity>> watchWorks() => remoteDataSource.watchWorks();

  @override
  Future<void> addWork(WorkEntity work, {WriteBatch? batch}) async {
    await remoteDataSource.addWork(
      WorkModel(
        id: work.id,
        title: work.title,
        contentCategory: work.contentCategory,
        isTranslation: work.isTranslation,
        language: work.language,
        genre: work.genre,
        originalTitle: work.originalTitle,
        originalLanguage: work.originalLanguage,
        notes: work.notes,
        authorIds: work.authorIds,
        translatorIds: work.translatorIds,
        sequenceVolumeIds: work.sequenceVolumeIds,
        bookId: work.bookId,
        createdDate: work.createdDate,
        lastUpdated: work.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
      newSequenceVolumeIds: work.sequenceVolumeIds,
      newBookId: work.bookId,
      batch: batch,
    );
  }

  @override
  Future<void> editWork(WorkEntity work, {WriteBatch? batch}) async {
    final WorkModel? existingWork = await remoteDataSource.fetchWorkById(work.id);

    await remoteDataSource.editWork(
      WorkModel(
        id: work.id,
        title: work.title,
        contentCategory: work.contentCategory,
        isTranslation: work.isTranslation,
        language: work.language,
        genre: work.genre,
        originalTitle: work.originalTitle,
        originalLanguage: work.originalLanguage,
        notes: work.notes,
        authorIds: work.authorIds,
        translatorIds: work.translatorIds,
        sequenceVolumeIds: work.sequenceVolumeIds,
        bookId: work.bookId,
        createdDate: work.createdDate,
        lastUpdated: work.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncWorkRelationships(
      workId: work.id,
      newAuthorIds: work.authorIds,
      newTranslatorIds: work.translatorIds,
      newSequenceVolumeIds: work.sequenceVolumeIds,
      newBookId: work.bookId,
      oldAuthorIds: existingWork?.authorIds ?? <String>[],
      oldTranslatorIds: existingWork?.translatorIds ?? <String>[],
      oldSequenceVolumeIds: existingWork?.sequenceVolumeIds ?? <String>[],
      oldBookId: existingWork?.bookId,
      batch: batch,
    );
  }

  @override
  Future<void> removeWork(String id, {WriteBatch? batch}) async {
    final WorkModel? existingWork = await remoteDataSource.fetchWorkById(id);

    if (existingWork != null) {
      await relationshipSyncService.removeWorkRelationships(
        workId: id,
        authorIds: existingWork.authorIds,
        translatorIds: existingWork.translatorIds,
        sequenceVolumeIds: existingWork.sequenceVolumeIds,
        bookId: existingWork.bookId,
        batch: batch,
      );
    }

    await remoteDataSource.removeWork(id, batch: batch);
  }

  @override
  Future<WorkEntity> upsertWork(
    WorkEntity work,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
    bool applyToBooks, {
    WriteBatch? batch,
  }) async {
    final WriteBatch effectiveBatch = batch ?? firestore.batch();
    final List<String> sequenceVolumeIds = await sequenceVolumeRepository.syncWorkVolumes(
      work.id,
      sequenceIdToVolume,
      isEdit,
      batch: effectiveBatch,
    );
    final WorkEntity workToSave = work.copyWith(sequenceVolumeIds: sequenceVolumeIds);

    if (isEdit) {
      await editWork(workToSave, batch: effectiveBatch);
    } else {
      await addWork(workToSave, batch: effectiveBatch);
    }

    if (applyToBooks && workToSave.bookId != null) {
      final BookModel? book = await bookRemoteDataSource.fetchBookById(workToSave.bookId!);

      if (book != null) {
        final BookEntity updatedBookEntity = book.copyWith(
          isTranslation: workToSave.isTranslation,
          authorIds: workToSave.authorIds,
          translatorIds: workToSave.translatorIds,
          language: Nullable<Language?>(workToSave.language),
          originalLanguage: Nullable<OriginalLanguage?>(workToSave.originalLanguage),
        );
        final BookModel updatedBook = BookModel(
          id: updatedBookEntity.id,
          title: updatedBookEntity.title,
          compilationType: updatedBookEntity.compilationType,
          isTranslation: updatedBookEntity.isTranslation,
          cover: updatedBookEntity.cover,
          language: updatedBookEntity.language,
          genre: updatedBookEntity.genre,
          isbn: updatedBookEntity.isbn,
          publishedDate: updatedBookEntity.publishedDate,
          noOfPages: updatedBookEntity.noOfPages,
          originalTitle: updatedBookEntity.originalTitle,
          originalLanguage: updatedBookEntity.originalLanguage,
          collectionStatus: updatedBookEntity.collectionStatus,
          collectedDate: updatedBookEntity.collectedDate,
          lendedDate: updatedBookEntity.lendedDate,
          dueDate: updatedBookEntity.dueDate,
          readingStatus: updatedBookEntity.readingStatus,
          pausedPage: updatedBookEntity.pausedPage,
          completedDate: updatedBookEntity.completedDate,
          notes: updatedBookEntity.notes,
          authorIds: updatedBookEntity.authorIds,
          translatorIds: updatedBookEntity.translatorIds,
          workIds: updatedBookEntity.workIds,
          sequenceVolumeIds: updatedBookEntity.sequenceVolumeIds,
          publisherId: updatedBookEntity.publisherId,
          readerId: updatedBookEntity.readerId,
          createdDate: updatedBookEntity.createdDate,
          lastUpdated: updatedBookEntity.lastUpdated,
        );

        await bookRemoteDataSource.editBook(updatedBook, batch: effectiveBatch);
      }
    }

    if (batch == null) {
      await effectiveBatch.commit();
    }

    return workToSave;
  }
}

@riverpod
WorkRepository workRepository(Ref ref) {
  final WorkRemoteDataSource remoteDataSource = ref.watch(workRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );
  final FirebaseFirestore firestore = ref.watch(firebaseFirestoreProvider);
  final SequenceVolumeRepository sequenceVolumeRepository = ref.watch(
    sequenceVolumeRepositoryProvider,
  );
  final BookRemoteDataSource bookRemoteDataSource = ref.watch(bookRemoteDataSourceProvider);

  return WorkRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
    firestore: firestore,
    sequenceVolumeRepository: sequenceVolumeRepository,
    bookRemoteDataSource: bookRemoteDataSource,
  );
}
