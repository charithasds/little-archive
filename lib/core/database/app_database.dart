import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

// --- TABLE DEFINITIONS ---

class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get compilationType => text()();
  BoolColumn get isTranslation => boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get toBeTranslated => boolean().withDefault(const Constant<bool>(false))();
  TextColumn get cover => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get isbn => text().nullable()();
  DateTimeColumn get publishedDate => dateTime().nullable()();
  IntColumn get noOfPages => integer().nullable()();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  TextColumn get collectionStatus => text()();
  DateTimeColumn get collectedDate => dateTime().nullable()();
  DateTimeColumn get lendedDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get readingStatus => text()();
  IntColumn get pausedPage => integer().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get publisherId => text().nullable()();
  TextColumn get readerId => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Publishers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isSelfPublisher => boolean().withDefault(const Constant<bool>(false))();
  TextColumn get logo => text().nullable()();
  TextColumn get otherName => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get facebook => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get bookFairPublisherId => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

enum CreatorRole { author, translator }

class Creators extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get image => text().nullable()();
  TextColumn get otherName => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get facebook => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Translators extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get image => text().nullable()();
  TextColumn get otherName => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get facebook => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Works extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get contentCategory => text()();
  BoolColumn get isTranslation => boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get toBeTranslated => boolean().withDefault(const Constant<bool>(false))();
  TextColumn get language => text().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get bookId => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Sequences extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class SequenceVolumes extends Table {
  TextColumn get id => text()();
  TextColumn get volume => text()();
  TextColumn get sequenceId => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get workId => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Readers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get image => text().nullable()();
  TextColumn get otherName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get facebook => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

// Many-to-Many Relationships Join Tables

class BookCreatorsJoin extends Table {
  TextColumn get bookId => text().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get creatorId => text().references(Creators, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => textEnum<CreatorRole>()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{bookId, creatorId, role};
}

class WorkCreatorsJoin extends Table {
  TextColumn get workId => text().references(Works, #id, onDelete: KeyAction.cascade)();
  TextColumn get creatorId => text().references(Creators, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => textEnum<CreatorRole>()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{workId, creatorId, role};
}

// --- DATABASE CLASS ---

@DriftDatabase(tables: <Type>[
  Books,
  Publishers,
  Creators,
  Translators,
  Works,
  Sequences,
  SequenceVolumes,
  Readers,
  BookCreatorsJoin,
  WorkCreatorsJoin,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1 && to == 2) {
            // 1. Create new tables
            await m.createTable(creators);
            await m.createTable(bookCreatorsJoin);
            await m.createTable(workCreatorsJoin);

            // 2. Migrate Authors into Creators
            await customStatement('''
              INSERT INTO creators (id, name, image, other_name, website, facebook, created_date, last_updated)
              SELECT id, name, image, other_name, website, facebook, created_date, last_updated
              FROM authors;
            ''');

            // 3. Migrate BookAuthorsJoin -> BookCreatorsJoin (role: author)
            await customStatement('''
              INSERT INTO book_creators_join (book_id, creator_id, role)
              SELECT book_id, author_id, 'author'
              FROM book_authors_join;
            ''');

            // 4. Migrate WorkAuthorsJoin -> WorkCreatorsJoin (role: author)
            await customStatement('''
              INSERT INTO work_creators_join (work_id, creator_id, role)
              SELECT work_id, author_id, 'author'
              FROM work_authors_join;
            ''');

            // 4.5. Migrate BookTranslatorsJoin -> BookCreatorsJoin (role: translator)
            await customStatement('''
              INSERT INTO book_creators_join (book_id, creator_id, role)
              SELECT book_id, translator_id, 'translator'
              FROM book_translators_join;
            ''');

            // 4.6. Migrate WorkTranslatorsJoin -> WorkCreatorsJoin (role: translator)
            await customStatement('''
              INSERT INTO work_creators_join (work_id, creator_id, role)
              SELECT work_id, translator_id, 'translator'
              FROM work_translators_join;
            ''');

            // 5. Delete old Authors table and old join tables
            await customStatement('DROP TABLE IF EXISTS authors;');
            await customStatement('DROP TABLE IF EXISTS book_authors_join;');
            await customStatement('DROP TABLE IF EXISTS work_authors_join;');
            await customStatement('DROP TABLE IF EXISTS book_translators_join;');
            await customStatement('DROP TABLE IF EXISTS work_translators_join;');

            // We intentionally leave Translators table intact here.
            // The mapping UI will query Translators, and map them to Creators.
          }
        },
      );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'little_archive.db'));
    return NativeDatabase(file);
  });

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
