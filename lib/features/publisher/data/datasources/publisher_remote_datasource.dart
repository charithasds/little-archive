import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../models/publisher_model.dart';

part 'publisher_remote_datasource.g.dart';

abstract class PublisherRemoteDataSource {
  String generateId();
  Future<List<PublisherModel>> fetchPublishers();
  Future<PublisherModel?> fetchPublisherById(String id);
  Stream<List<PublisherModel>> watchPublishers();
  Future<void> addPublisher(PublisherModel publisher);
  Future<void> editPublisher(PublisherModel publisher);
  Future<void> removePublisher(String id);
}

class PublisherRemoteDataSourceImpl implements PublisherRemoteDataSource {
  PublisherRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return List<String>.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<PublisherModel> _mapToPublisherModel(Publisher row) async {
    // Resolve bookIds where publisherId == row.id
    final SimpleSelectStatement<$BooksTable, Book> booksQuery = db.select(db.books)..where(($BooksTable t) => t.publisherId.equals(row.id));
    final List<Book> books = await booksQuery.get();
    final List<String> bookIds = books.map((Book b) => b.id).toList();

    return PublisherModel(
      id: row.id,
      name: row.name,
      isSelfPublisher: row.isSelfPublisher,
      logo: row.logo,
      otherName: row.otherName,
      website: row.website,
      email: row.email,
      facebook: row.facebook,
      phoneNumber: row.phoneNumber,
      bookIds: bookIds,
      bookFairPublisherId: row.bookFairPublisherId,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );
  }

  @override
  Future<List<PublisherModel>> fetchPublishers() async {
    final SimpleSelectStatement<$PublishersTable, Publisher> query = db.select(db.publishers)..orderBy(<OrderClauseGenerator<$PublishersTable>>[($PublishersTable t) => OrderingTerm(expression: t.name)]);
    final List<Publisher> rows = await query.get();
    final List<PublisherModel> publishers = <PublisherModel>[];
    for (final Publisher row in rows) {
      publishers.add(await _mapToPublisherModel(row));
    }
    return publishers;
  }

  @override
  Future<PublisherModel?> fetchPublisherById(String id) async {
    final SimpleSelectStatement<$PublishersTable, Publisher> query = db.select(db.publishers)..where(($PublishersTable t) => t.id.equals(id));
    final Publisher? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToPublisherModel(row);
  }

  @override
  Stream<List<PublisherModel>> watchPublishers() async* {
    yield await fetchPublishers();
    await for (final Set<TableUpdate> _ in db.tableUpdates().where((Set<TableUpdate> updates) => updates.any((TableUpdate update) =>
        update.table == db.publishers.actualTableName ||
        update.table == db.books.actualTableName))) {
      yield await fetchPublishers();
    }
  }

  @override
  Future<void> addPublisher(PublisherModel publisher) async {
    await db.into(db.publishers).insertOnConflictUpdate(
      Publisher(
        id: publisher.id,
        name: publisher.name,
        isSelfPublisher: publisher.isSelfPublisher,
        logo: publisher.logo,
        otherName: publisher.otherName,
        website: publisher.website,
        email: publisher.email,
        facebook: publisher.facebook,
        phoneNumber: publisher.phoneNumber,
        bookFairPublisherId: publisher.bookFairPublisherId,
        createdDate: publisher.createdDate,
        lastUpdated: publisher.lastUpdated,
      ).toCompanion(false),
    );
  }

  @override
  Future<void> editPublisher(PublisherModel publisher) async {
    await addPublisher(publisher);
  }

  @override
  Future<void> removePublisher(String id) async {
    await (db.delete(db.publishers)..where(($PublishersTable t) => t.id.equals(id))).go();
  }
}

@riverpod
PublisherRemoteDataSource publisherRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return PublisherRemoteDataSourceImpl(db: db);
}
