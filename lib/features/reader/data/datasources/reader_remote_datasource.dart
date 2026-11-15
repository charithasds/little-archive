import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../models/reader_model.dart';

part 'reader_remote_datasource.g.dart';

abstract class ReaderRemoteDataSource {
  String generateId();
  Future<List<ReaderModel>> fetchReaders();
  Future<ReaderModel?> fetchReaderById(String id);
  Stream<List<ReaderModel>> watchReaders();
  Future<void> addReader(ReaderModel reader);
  Future<void> editReader(ReaderModel reader);
  Future<void> removeReader(String id);
}

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  ReaderRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return List<String>.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  ReaderModel _buildReaderModel(Reader row, {required List<String> bookIds}) => ReaderModel(
    id: row.id,
    name: row.name,
    image: row.image,
    otherName: row.otherName,
    email: row.email,
    facebook: row.facebook,
    phoneNumber: row.phoneNumber,
    bookIds: bookIds,
    createdDate: row.createdDate,
    lastUpdated: row.lastUpdated,
  );

  Future<ReaderModel> _mapToReaderModel(Reader row) async {
    final JoinedSelectStatement<$BooksTable, Book> booksQuery = db.selectOnly(db.books)
      ..addColumns(<Expression<Object>>[db.books.id])
      ..where(db.books.readerId.equals(row.id));
    final List<TypedResult> bookRows = await booksQuery.get();
    final List<String> bookIds = bookRows
        .map((TypedResult r) => r.read(db.books.id))
        .whereType<String>()
        .toList();

    return _buildReaderModel(row, bookIds: bookIds);
  }

  @override
  Future<List<ReaderModel>> fetchReaders() async {
    final SimpleSelectStatement<$ReadersTable, Reader> query = db.select(db.readers)
      ..orderBy(<OrderClauseGenerator<$ReadersTable>>[
        ($ReadersTable t) => OrderingTerm(expression: t.name),
      ]);
    final List<Reader> rows = await query.get();
    if (rows.isEmpty) {
      return <ReaderModel>[];
    }

    final JoinedSelectStatement<$BooksTable, Book> booksQuery = db.selectOnly(db.books)
      ..addColumns(<Expression<Object>>[db.books.id, db.books.readerId])
      ..where(db.books.readerId.isNotNull());
    final List<TypedResult> bookRows = await booksQuery.get();

    final Map<String, List<String>> booksByReader = <String, List<String>>{};
    for (final TypedResult r in bookRows) {
      final String? bookId = r.read(db.books.id);
      final String? readerId = r.read(db.books.readerId);
      if (bookId != null && readerId != null) {
        (booksByReader[readerId] ??= <String>[]).add(bookId);
      }
    }

    return rows
        .map(
          (Reader row) => _buildReaderModel(
            row,
            bookIds: booksByReader[row.id] ?? const <String>[],
          ),
        )
        .toList();
  }

  @override
  Future<ReaderModel?> fetchReaderById(String id) async {
    final SimpleSelectStatement<$ReadersTable, Reader> query = db.select(db.readers)..where(($ReadersTable t) => t.id.equals(id));
    final Reader? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToReaderModel(row);
  }

  @override
  Stream<List<ReaderModel>> watchReaders() async* {
    yield await fetchReaders();
    await for (final Set<TableUpdate> _ in db.tableUpdates().where((Set<TableUpdate> updates) => updates.any((TableUpdate update) =>
        update.table == db.readers.actualTableName ||
        update.table == db.books.actualTableName))) {
      yield await fetchReaders();
    }
  }

  @override
  Future<void> addReader(ReaderModel reader) async {
    await db.into(db.readers).insertOnConflictUpdate(
      Reader(
        id: reader.id,
        name: reader.name,
        image: reader.image,
        otherName: reader.otherName,
        email: reader.email,
        facebook: reader.facebook,
        phoneNumber: reader.phoneNumber,
        createdDate: reader.createdDate,
        lastUpdated: reader.lastUpdated,
      ).toCompanion(false),
    );
  }

  @override
  Future<void> editReader(ReaderModel reader) async {
    await addReader(reader);
  }

  @override
  Future<void> removeReader(String id) async {
    await (db.delete(db.readers)..where(($ReadersTable t) => t.id.equals(id))).go();
  }
}

@riverpod
ReaderRemoteDataSource readerRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return ReaderRemoteDataSourceImpl(db: db);
}
