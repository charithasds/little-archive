import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../models/author_model.dart';

part 'author_remote_datasource.g.dart';

abstract class AuthorRemoteDataSource {
  String generateId();
  Future<List<AuthorModel>> fetchAuthors();
  Future<AuthorModel?> fetchAuthorById(String id);
  Stream<List<AuthorModel>> watchAuthors();
  Future<void> addAuthor(AuthorModel author);
  Future<void> editAuthor(AuthorModel author);
  Future<void> removeAuthor(String id);
}

class AuthorRemoteDataSourceImpl implements AuthorRemoteDataSource {
  AuthorRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '').replaceAll('-', '').replaceAll('_', '').substring(0, 20);
  }

  Future<AuthorModel> _mapToAuthorModel(Author row) async {
    // Resolve bookIds from bookAuthorsJoin table
    final SimpleSelectStatement<$BookAuthorsJoinTable, BookAuthorsJoinData> booksQuery = db.select(db.bookAuthorsJoin)..where(($BookAuthorsJoinTable t) => t.authorId.equals(row.id));
    final List<BookAuthorsJoinData> books = await booksQuery.get();
    final List<String> bookIds = books.map((BookAuthorsJoinData b) => b.bookId).toList();

    // Resolve workIds from workAuthorsJoin table
    final SimpleSelectStatement<$WorkAuthorsJoinTable, WorkAuthorsJoinData> worksQuery = db.select(db.workAuthorsJoin)..where(($WorkAuthorsJoinTable t) => t.authorId.equals(row.id));
    final List<WorkAuthorsJoinData> works = await worksQuery.get();
    final List<String> workIds = works.map((WorkAuthorsJoinData w) => w.workId).toList();

    return AuthorModel(
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
  Future<List<AuthorModel>> fetchAuthors() async {
    final SimpleSelectStatement<$AuthorsTable, Author> query = db.select(db.authors)..orderBy(<OrderClauseGenerator<$AuthorsTable>>[($AuthorsTable t) => OrderingTerm(expression: t.name)]);
    final List<Author> rows = await query.get();
    final List<AuthorModel> authors = <AuthorModel>[];
    for (final Author row in rows) {
      authors.add(await _mapToAuthorModel(row));
    }
    return authors;
  }

  @override
  Future<AuthorModel?> fetchAuthorById(String id) async {
    final SimpleSelectStatement<$AuthorsTable, Author> query = db.select(db.authors)..where(($AuthorsTable t) => t.id.equals(id));
    final Author? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToAuthorModel(row);
  }

  @override
  Stream<List<AuthorModel>> watchAuthors() => db.select(db.authors).watch().asyncMap((List<Author> rows) async {
      final List<AuthorModel> authors = <AuthorModel>[];
      for (final Author row in rows) {
        authors.add(await _mapToAuthorModel(row));
      }
      return authors;
    });

  @override
  Future<void> addAuthor(AuthorModel author) async {
    await db.into(db.authors).insertOnConflictUpdate(
      Author(
        id: author.id,
        name: author.name,
        image: author.image,
        otherName: author.otherName,
        website: author.website,
        facebook: author.facebook,
        createdDate: author.createdDate,
        lastUpdated: author.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editAuthor(AuthorModel author) async {
    await addAuthor(author);
  }

  @override
  Future<void> removeAuthor(String id) async {
    await (db.delete(db.authors)..where(($AuthorsTable t) => t.id.equals(id))).go();
  }
}

@riverpod
AuthorRemoteDataSource authorRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return AuthorRemoteDataSourceImpl(db: db);
}
