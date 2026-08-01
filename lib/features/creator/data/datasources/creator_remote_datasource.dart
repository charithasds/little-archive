import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../models/creator_model.dart';

part 'creator_remote_datasource.g.dart';

abstract class CreatorRemoteDataSource {
  String generateId();
  Future<List<CreatorModel>> fetchCreators();
  Future<CreatorModel?> fetchCreatorById(String id);
  Stream<List<CreatorModel>> watchCreators();
  Future<void> addCreator(CreatorModel creator);
  Future<void> editCreator(CreatorModel creator);
  Future<void> removeCreator(String id);
  Future<void> mergeCreators(String targetId, String sourceId);
  Future<void> keepTranslatorAsIs(String translatorId);
  Future<void> mapTranslatorToCreator(String translatorId, String creatorId);
  Future<List<CreatorModel>> fetchUnmappedTranslators();
}

class CreatorRemoteDataSourceImpl implements CreatorRemoteDataSource {
  CreatorRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return List<String>.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<CreatorModel> _mapToCreatorModel(Creator row) async {
    // Resolve authored bookIds from BookCreatorsJoin
    final SimpleSelectStatement<$BookCreatorsJoinTable, BookCreatorsJoinData> authBooksQuery =
        db.select(db.bookCreatorsJoin)..where(
          ($BookCreatorsJoinTable t) =>
              t.creatorId.equals(row.id) & t.role.equals(CreatorRole.author.name),
        );
    final List<BookCreatorsJoinData> authBooks = await authBooksQuery.get();

    // Resolve translated bookIds from BookCreatorsJoin
    final SimpleSelectStatement<$BookCreatorsJoinTable, BookCreatorsJoinData> transBooksQuery =
        db.select(db.bookCreatorsJoin)..where(
          ($BookCreatorsJoinTable t) =>
              t.creatorId.equals(row.id) & t.role.equals(CreatorRole.translator.name),
        );
    final List<BookCreatorsJoinData> transBooks = await transBooksQuery.get();

    final List<String> authoredBookIds = authBooks
        .map((BookCreatorsJoinData b) => b.bookId)
        .toList();
    final List<String> translatedBookIds = transBooks
        .map((BookCreatorsJoinData b) => b.bookId)
        .toList();

    // Resolve authored workIds from WorkCreatorsJoin
    final SimpleSelectStatement<$WorkCreatorsJoinTable, WorkCreatorsJoinData> authWorksQuery =
        db.select(db.workCreatorsJoin)..where(
          ($WorkCreatorsJoinTable t) =>
              t.creatorId.equals(row.id) & t.role.equals(CreatorRole.author.name),
        );
    final List<WorkCreatorsJoinData> authWorks = await authWorksQuery.get();

    // Resolve translated workIds from WorkCreatorsJoin
    final SimpleSelectStatement<$WorkCreatorsJoinTable, WorkCreatorsJoinData> transWorksQuery =
        db.select(db.workCreatorsJoin)..where(
          ($WorkCreatorsJoinTable t) =>
              t.creatorId.equals(row.id) & t.role.equals(CreatorRole.translator.name),
        );
    final List<WorkCreatorsJoinData> transWorks = await transWorksQuery.get();

    final List<String> authoredWorkIds = authWorks
        .map((WorkCreatorsJoinData w) => w.workId)
        .toList();
    final List<String> translatedWorkIds = transWorks
        .map((WorkCreatorsJoinData w) => w.workId)
        .toList();

    return CreatorModel(
      id: row.id,
      name: row.name,
      image: row.image,
      otherName: row.otherName,
      website: row.website,
      facebook: row.facebook,
      authoredBookIds: authoredBookIds,
      translatedBookIds: translatedBookIds,
      authoredWorkIds: authoredWorkIds,
      translatedWorkIds: translatedWorkIds,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );
  }

  @override
  Future<List<CreatorModel>> fetchCreators() async {
    final SimpleSelectStatement<$CreatorsTable, Creator> query = db.select(db.creators)
      ..orderBy(<OrderClauseGenerator<$CreatorsTable>>[
        ($CreatorsTable t) => OrderingTerm(expression: t.name),
      ]);
    final List<Creator> rows = await query.get();
    final List<CreatorModel> creators = <CreatorModel>[];
    for (final Creator row in rows) {
      creators.add(await _mapToCreatorModel(row));
    }
    return creators;
  }

  @override
  Future<CreatorModel?> fetchCreatorById(String id) async {
    final SimpleSelectStatement<$CreatorsTable, Creator> query = db.select(db.creators)
      ..where(($CreatorsTable t) => t.id.equals(id));
    final Creator? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToCreatorModel(row);
  }

  @override
  Stream<List<CreatorModel>> watchCreators() async* {
    yield await fetchCreators();
    await for (final Set<TableUpdate> _ in db.tableUpdates().where(
      (Set<TableUpdate> updates) => updates.any(
        (TableUpdate update) =>
            update.table == db.creators.actualTableName ||
            update.table == db.bookCreatorsJoin.actualTableName ||
            update.table == db.workCreatorsJoin.actualTableName ||
            update.table == db.books.actualTableName ||
            update.table == db.works.actualTableName,
      ),
    )) {
      yield await fetchCreators();
    }
  }

  @override
  Future<void> addCreator(CreatorModel creator) async {
    await db
        .into(db.creators)
        .insertOnConflictUpdate(
          Creator(
            id: creator.id,
            name: creator.name,
            image: creator.image,
            otherName: creator.otherName,
            website: creator.website,
            facebook: creator.facebook,
            createdDate: creator.createdDate,
            lastUpdated: creator.lastUpdated,
          ).toCompanion(false),
        );
  }

  @override
  Future<void> editCreator(CreatorModel creator) async {
    await addCreator(creator);
  }

  @override
  Future<void> removeCreator(String id) async {
    await (db.delete(db.creators)..where(($CreatorsTable t) => t.id.equals(id))).go();
  }

  @override
  Future<void> mergeCreators(String targetId, String sourceId) async {
    await db.transaction(() async {
      // Update join tables to point to targetId
      await db.customStatement(
        '''
        UPDATE OR IGNORE book_creators_join
        SET creator_id = ?
        WHERE creator_id = ?;
      ''',
        <dynamic>[targetId, sourceId],
      );

      await db.customStatement(
        '''
        UPDATE OR IGNORE work_creators_join
        SET creator_id = ?
        WHERE creator_id = ?;
      ''',
        <dynamic>[targetId, sourceId],
      );

      // Delete remaining source join entries if there were duplicates
      await (db.delete(
        db.bookCreatorsJoin,
      )..where(($BookCreatorsJoinTable t) => t.creatorId.equals(sourceId))).go();
      await (db.delete(
        db.workCreatorsJoin,
      )..where(($WorkCreatorsJoinTable t) => t.creatorId.equals(sourceId))).go();

      await removeCreator(sourceId);
    });
  }

  @override
  Future<void> keepTranslatorAsIs(String translatorId) async {
    await db.transaction(() async {
      // Get the translator from the temporary Translators table
      final SimpleSelectStatement<$TranslatorsTable, Translator> query = db.select(db.translators)
        ..where(($TranslatorsTable t) => t.id.equals(translatorId));
      final Translator? translator = await query.getSingleOrNull();

      if (translator == null) {
        throw Exception('Translator not found in queue');
      }

      // Insert them into Creators
      await db
          .into(db.creators)
          .insertOnConflictUpdate(
            Creator(
              id: translator.id,
              name: translator.name,
              image: translator.image,
              otherName: translator.otherName,
              website: translator.website,
              facebook: translator.facebook,
              createdDate: translator.createdDate,
              lastUpdated: translator.lastUpdated,
            ).toCompanion(false),
          );

      // Update book_creators_join where role='translator' and we temporarily used translatorId
      // Wait, in schema v2 we migrated old translators into creators.
      // But the manual workaround left the old Translators table and old join tables!
      // No, in our schema v2, the join tables are BookCreatorsJoin. If we use the queue,
      // where did the book links for the unmapped translator go?
      // Ah! In onUpgrade we migrated BookTranslatorsJoin to BookCreatorsJoin using the translator_id!
      // So the book_creators_join table ALREADY points to the translatorId, but the creator record is missing because we didn't insert Translators into Creators.
      // So keeping them as is just means inserting them into Creators and deleting from the queue!

      // Delete from queue
      await (db.delete(
        db.translators,
      )..where(($TranslatorsTable t) => t.id.equals(translatorId))).go();
    });
  }

  @override
  Future<void> mapTranslatorToCreator(String translatorId, String creatorId) async {
    await db.transaction(() async {
      // The target creator already exists in Creators table.
      // The join tables BookCreatorsJoin and WorkCreatorsJoin have translatorId (because we copied from book_translators_join using the old ID).
      // We just need to update the join tables to point to creatorId instead of translatorId.

      await db.customStatement(
        '''
        UPDATE OR IGNORE book_creators_join
        SET creator_id = ?
        WHERE creator_id = ? AND role = 'translator';
      ''',
        <dynamic>[creatorId, translatorId],
      );

      await db.customStatement(
        '''
        UPDATE OR IGNORE work_creators_join
        SET creator_id = ?
        WHERE creator_id = ? AND role = 'translator';
      ''',
        <dynamic>[creatorId, translatorId],
      );

      // Delete any remaining source join entries if there were duplicates
      await (db.delete(
        db.bookCreatorsJoin,
      )..where(($BookCreatorsJoinTable t) => t.creatorId.equals(translatorId))).go();
      await (db.delete(
        db.workCreatorsJoin,
      )..where(($WorkCreatorsJoinTable t) => t.creatorId.equals(translatorId))).go();

      // Delete the old translator from Translators table queue
      await (db.delete(
        db.translators,
      )..where(($TranslatorsTable t) => t.id.equals(translatorId))).go();
    });
  }

  @override
  Future<List<CreatorModel>> fetchUnmappedTranslators() async {
    final SimpleSelectStatement<$TranslatorsTable, Translator> query = db.select(db.translators)
      ..orderBy(<OrderClauseGenerator<$TranslatorsTable>>[
        ($TranslatorsTable t) => OrderingTerm(expression: t.name),
      ]);
    final List<Translator> rows = await query.get();

    return rows
        .map(
          (Translator row) => CreatorModel(
            id: row.id,
            name: row.name,
            image: row.image,
            otherName: row.otherName,
            website: row.website,
            facebook: row.facebook,
            authoredBookIds: const <String>[],
            translatedBookIds: const <String>[],
            authoredWorkIds: const <String>[],
            translatedWorkIds: const <String>[],
            createdDate: row.createdDate,
            lastUpdated: row.lastUpdated,
          ),
        )
        .toList();
  }
}

@riverpod
CreatorRemoteDataSource creatorRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return CreatorRemoteDataSourceImpl(db: db);
}
