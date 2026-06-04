import 'dart:convert';
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
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '').replaceAll('-', '').replaceAll('_', '').substring(0, 20);
  }

  Future<ReaderModel> _mapToReaderModel(Reader row) async {
    // Resolve bookIds where readerId == row.id
    final SimpleSelectStatement<$BooksTable, Book> booksQuery = db.select(db.books)..where(($BooksTable t) => t.readerId.equals(row.id));
    final List<Book> books = await booksQuery.get();
    final List<String> bookIds = books.map((Book b) => b.id).toList();

    return ReaderModel(
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
  }

  @override
  Future<List<ReaderModel>> fetchReaders() async {
    final SimpleSelectStatement<$ReadersTable, Reader> query = db.select(db.readers)..orderBy(<OrderClauseGenerator<$ReadersTable>>[($ReadersTable t) => OrderingTerm(expression: t.name)]);
    final List<Reader> rows = await query.get();
    final List<ReaderModel> readerModels = <ReaderModel>[];
    for (final Reader row in rows) {
      readerModels.add(await _mapToReaderModel(row));
    }
    return readerModels;
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
  Stream<List<ReaderModel>> watchReaders() => db.select(db.readers).watch().asyncMap((List<Reader> rows) async {
      final List<ReaderModel> readerModels = <ReaderModel>[];
      for (final Reader row in rows) {
        readerModels.add(await _mapToReaderModel(row));
      }
      return readerModels;
    });

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
      ),
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
