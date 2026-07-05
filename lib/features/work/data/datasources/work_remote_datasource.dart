import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../models/work_model.dart';

part 'work_remote_datasource.g.dart';

abstract class WorkRemoteDataSource {
  String generateId();
  Future<List<WorkModel>> fetchWorks();
  Future<WorkModel?> fetchWorkById(String id);
  Stream<List<WorkModel>> watchWorks();
  Future<void> addWork(WorkModel work);
  Future<void> editWork(WorkModel work);
  Future<void> removeWork(String id);
}

class WorkRemoteDataSourceImpl implements WorkRemoteDataSource {
  WorkRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return List<String>.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<WorkModel> _mapToWorkModel(Work row) async {
    // Resolve authorIds from workAuthorsJoin table
    final SimpleSelectStatement<$WorkAuthorsJoinTable, WorkAuthorsJoinData> authorsQuery = db.select(db.workAuthorsJoin)..where(($WorkAuthorsJoinTable t) => t.workId.equals(row.id));
    final List<WorkAuthorsJoinData> authors = await authorsQuery.get();
    final List<String> authorIds = authors.map((WorkAuthorsJoinData a) => a.authorId).toList();

    // Resolve translatorIds from workTranslatorsJoin table
    final SimpleSelectStatement<$WorkTranslatorsJoinTable, WorkTranslatorsJoinData> translatorsQuery = db.select(db.workTranslatorsJoin)..where(($WorkTranslatorsJoinTable t) => t.workId.equals(row.id));
    final List<WorkTranslatorsJoinData> translators = await translatorsQuery.get();
    final List<String> translatorIds = translators.map((WorkTranslatorsJoinData t) => t.translatorId).toList();

    // Resolve sequenceVolumeIds from sequenceVolumes table
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> volumesQuery = db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.workId.equals(row.id));
    final List<SequenceVolume> volumes = await volumesQuery.get();
    final List<String> sequenceVolumeIds = volumes.map((SequenceVolume v) => v.id).toList();

    return WorkModel(
      id: row.id,
      title: row.title,
      contentCategory: ContentCategory.values.asNameMap()[row.contentCategory] ?? ContentCategory.shortStory,
      isTranslation: row.isTranslation,
      toBeTranslated: row.toBeTranslated,
      language: Language.values.asNameMap()[row.language ?? ''],
      genre: Genre.values.asNameMap()[row.genre ?? ''],
      originalTitle: row.originalTitle,
      originalLanguage: OriginalLanguage.values.asNameMap()[row.originalLanguage ?? ''],
      notes: row.notes,
      authorIds: authorIds,
      translatorIds: translatorIds,
      sequenceVolumeIds: sequenceVolumeIds,
      bookId: row.bookId,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );
  }

  @override
  Future<List<WorkModel>> fetchWorks() async {
    final SimpleSelectStatement<$WorksTable, Work> query = db.select(db.works)..orderBy(<OrderClauseGenerator<$WorksTable>>[($WorksTable t) => OrderingTerm(expression: t.title)]);
    final List<Work> rows = await query.get();
    final List<WorkModel> works = <WorkModel>[];
    for (final Work row in rows) {
      works.add(await _mapToWorkModel(row));
    }
    return works;
  }

  @override
  Future<WorkModel?> fetchWorkById(String id) async {
    final SimpleSelectStatement<$WorksTable, Work> query = db.select(db.works)..where(($WorksTable t) => t.id.equals(id));
    final Work? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToWorkModel(row);
  }

  @override
  Stream<List<WorkModel>> watchWorks() async* {
    yield await fetchWorks();
    await for (final Set<TableUpdate> _ in db.tableUpdates().where((Set<TableUpdate> updates) => updates.any((TableUpdate update) =>
        update.table == db.works.actualTableName ||
        update.table == db.workAuthorsJoin.actualTableName ||
        update.table == db.workTranslatorsJoin.actualTableName ||
        update.table == db.sequenceVolumes.actualTableName ||
        update.table == db.books.actualTableName))) {
      yield await fetchWorks();
    }
  }

  @override
  Future<void> addWork(WorkModel work) async {
    await db.transaction(() async {
      await db.into(db.works).insertOnConflictUpdate(
        Work(
          id: work.id,
          title: work.title,
          contentCategory: work.contentCategory.name,
          isTranslation: work.isTranslation,
          toBeTranslated: work.toBeTranslated,
          language: work.language?.name,
          genre: work.genre?.name,
          originalTitle: work.originalTitle,
          originalLanguage: work.originalLanguage?.name,
          notes: work.notes,
          bookId: work.bookId,
          createdDate: work.createdDate,
          lastUpdated: work.lastUpdated,
        ).toCompanion(false),
      );

      // Sync Work-Author Joins
      await (db.delete(db.workAuthorsJoin)..where(($WorkAuthorsJoinTable t) => t.workId.equals(work.id))).go();
      for (final String authorId in work.authorIds) {
        await db.into(db.workAuthorsJoin).insertOnConflictUpdate(
          WorkAuthorsJoinCompanion.insert(workId: work.id, authorId: authorId),
        );
      }

      // Sync Work-Translator Joins
      await (db.delete(db.workTranslatorsJoin)..where(($WorkTranslatorsJoinTable t) => t.workId.equals(work.id))).go();
      for (final String translatorId in work.translatorIds) {
        await db.into(db.workTranslatorsJoin).insertOnConflictUpdate(
          WorkTranslatorsJoinCompanion.insert(workId: work.id, translatorId: translatorId),
        );
      }
    });
  }

  @override
  Future<void> editWork(WorkModel work) async {
    await addWork(work);
  }

  @override
  Future<void> removeWork(String id) async {
    await db.transaction(() async {
      await (db.delete(db.works)..where(($WorksTable t) => t.id.equals(id))).go();
      await (db.delete(db.workAuthorsJoin)..where(($WorkAuthorsJoinTable t) => t.workId.equals(id))).go();
      await (db.delete(db.workTranslatorsJoin)..where(($WorkTranslatorsJoinTable t) => t.workId.equals(id))).go();
    });
  }
}

@riverpod
WorkRemoteDataSource workRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return WorkRemoteDataSourceImpl(db: db);
}
