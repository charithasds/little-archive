import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../models/translator_model.dart';

part 'translator_remote_datasource.g.dart';

abstract class TranslatorRemoteDataSource {
  String generateId();
  Future<List<TranslatorModel>> fetchTranslators();
  Future<TranslatorModel?> fetchTranslatorById(String id);
  Stream<List<TranslatorModel>> watchTranslators();
  Future<void> addTranslator(TranslatorModel translator);
  Future<void> editTranslator(TranslatorModel translator);
  Future<void> removeTranslator(String id);
}

class TranslatorRemoteDataSourceImpl implements TranslatorRemoteDataSource {
  TranslatorRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '').replaceAll('-', '').replaceAll('_', '').substring(0, 20);
  }

  Future<TranslatorModel> _mapToTranslatorModel(Translator row) async {
    // Resolve bookIds from bookTranslatorsJoin table
    final SimpleSelectStatement<$BookTranslatorsJoinTable, BookTranslatorsJoinData> booksQuery = db.select(db.bookTranslatorsJoin)..where(($BookTranslatorsJoinTable t) => t.translatorId.equals(row.id));
    final List<BookTranslatorsJoinData> books = await booksQuery.get();
    final List<String> bookIds = books.map((BookTranslatorsJoinData b) => b.bookId).toList();

    // Resolve workIds from workTranslatorsJoin table
    final SimpleSelectStatement<$WorkTranslatorsJoinTable, WorkTranslatorsJoinData> worksQuery = db.select(db.workTranslatorsJoin)..where(($WorkTranslatorsJoinTable t) => t.translatorId.equals(row.id));
    final List<WorkTranslatorsJoinData> works = await worksQuery.get();
    final List<String> workIds = works.map((WorkTranslatorsJoinData w) => w.workId).toList();

    return TranslatorModel(
      id: row.id,
      name: row.name,
      image: row.image,
      otherName: row.otherName,
      website: row.website,
      facebook: row.facebook,
      bookIds: bookIds,
      workIds: workIds,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );
  }

  @override
  Future<List<TranslatorModel>> fetchTranslators() async {
    final SimpleSelectStatement<$TranslatorsTable, Translator> query = db.select(db.translators)..orderBy(<OrderClauseGenerator<$TranslatorsTable>>[($TranslatorsTable t) => OrderingTerm(expression: t.name)]);
    final List<Translator> rows = await query.get();
    final List<TranslatorModel> translators = <TranslatorModel>[];
    for (final Translator row in rows) {
      translators.add(await _mapToTranslatorModel(row));
    }
    return translators;
  }

  @override
  Future<TranslatorModel?> fetchTranslatorById(String id) async {
    final SimpleSelectStatement<$TranslatorsTable, Translator> query = db.select(db.translators)..where(($TranslatorsTable t) => t.id.equals(id));
    final Translator? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToTranslatorModel(row);
  }

  @override
  Stream<List<TranslatorModel>> watchTranslators() => db.select(db.translators).watch().asyncMap((List<Translator> rows) async {
      final List<TranslatorModel> translators = <TranslatorModel>[];
      for (final Translator row in rows) {
        translators.add(await _mapToTranslatorModel(row));
      }
      return translators;
    });

  @override
  Future<void> addTranslator(TranslatorModel translator) async {
    await db.into(db.translators).insertOnConflictUpdate(
      Translator(
        id: translator.id,
        name: translator.name,
        image: translator.image,
        otherName: translator.otherName,
        website: translator.website,
        facebook: translator.facebook,
        createdDate: translator.createdDate,
        lastUpdated: translator.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editTranslator(TranslatorModel translator) async {
    await addTranslator(translator);
  }

  @override
  Future<void> removeTranslator(String id) async {
    await (db.delete(db.translators)..where(($TranslatorsTable t) => t.id.equals(id))).go();
  }
}

@riverpod
TranslatorRemoteDataSource translatorRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return TranslatorRemoteDataSourceImpl(db: db);
}
