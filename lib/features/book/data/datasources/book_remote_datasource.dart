import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../models/book_model.dart';

part 'book_remote_datasource.g.dart';

abstract class BookRemoteDataSource {
  String generateId();
  Future<List<BookModel>> fetchBooks();
  Future<BookModel?> fetchBookById(String id);
  Stream<List<BookModel>> watchBooks();
  Future<void> addBook(BookModel book);
  Future<void> editBook(BookModel book);
  Future<void> removeBook(String id);
  Future<Map<String, dynamic>> scanBookCover(Uint8List imageBytes);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  BookRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return List<String>.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<BookModel> _mapToBookModel(Book row) async {
    // Fetch associated relations from join tables
    final SimpleSelectStatement<$BookAuthorsJoinTable, BookAuthorsJoinData> authorsQuery = db.select(db.bookAuthorsJoin)..where(($BookAuthorsJoinTable t) => t.bookId.equals(row.id));
    final List<BookAuthorsJoinData> authors = await authorsQuery.get();
    final List<String> authorIds = authors.map((BookAuthorsJoinData a) => a.authorId).toList();

    final SimpleSelectStatement<$BookTranslatorsJoinTable, BookTranslatorsJoinData> translatorsQuery = db.select(db.bookTranslatorsJoin)..where(($BookTranslatorsJoinTable t) => t.bookId.equals(row.id));
    final List<BookTranslatorsJoinData> translators = await translatorsQuery.get();
    final List<String> translatorIds = translators.map((BookTranslatorsJoinData t) => t.translatorId).toList();

    // WorkIds: query work relation if applicable
    final SimpleSelectStatement<$WorksTable, Work> worksQuery = db.select(db.works)..where(($WorksTable t) => t.bookId.equals(row.id));
    final List<Work> works = await worksQuery.get();
    final List<String> workIds = works.map((Work w) => w.id).toList();

    // SequenceVolumeIds: query sequence volume relation
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> volumesQuery = db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.bookId.equals(row.id));
    final List<SequenceVolume> volumes = await volumesQuery.get();
    final List<String> sequenceVolumeIds = volumes.map((SequenceVolume v) => v.id).toList();

    return BookModel(
      id: row.id,
      title: row.title,
      compilationType: CompilationType.values.asNameMap()[row.compilationType] ?? CompilationType.single,
      isTranslation: row.isTranslation,
      toBeTranslated: row.toBeTranslated,
      cover: row.cover,
      language: Language.values.asNameMap()[row.language ?? ''],
      genre: Genre.values.asNameMap()[row.genre ?? ''],
      isbn: row.isbn,
      publishedDate: row.publishedDate,
      noOfPages: row.noOfPages,
      originalTitle: row.originalTitle,
      originalLanguage: OriginalLanguage.values.asNameMap()[row.originalLanguage ?? ''],
      collectionStatus: CollectionStatus.values.asNameMap()[row.collectionStatus] ?? CollectionStatus.collected,
      collectedDate: row.collectedDate,
      lendedDate: row.lendedDate,
      dueDate: row.dueDate,
      readingStatus: ReadingStatus.values.asNameMap()[row.readingStatus] ?? ReadingStatus.notStarted,
      pausedPage: row.pausedPage,
      completedDate: row.completedDate,
      notes: row.notes,
      authorIds: authorIds,
      translatorIds: translatorIds,
      workIds: workIds,
      sequenceVolumeIds: sequenceVolumeIds,
      publisherId: row.publisherId,
      readerId: row.readerId,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );
  }

  @override
  Future<List<BookModel>> fetchBooks() async {
    final SimpleSelectStatement<$BooksTable, Book> query = db.select(db.books)..orderBy(<OrderClauseGenerator<$BooksTable>>[($BooksTable t) => OrderingTerm(expression: t.title)]);
    final List<Book> rows = await query.get();
    final List<BookModel> books = <BookModel>[];
    for (final Book row in rows) {
      books.add(await _mapToBookModel(row));
    }
    return books;
  }

  @override
  Future<BookModel?> fetchBookById(String id) async {
    final SimpleSelectStatement<$BooksTable, Book> query = db.select(db.books)..where(($BooksTable t) => t.id.equals(id));
    final Book? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToBookModel(row);
  }

  @override
  Stream<List<BookModel>> watchBooks() async* {
    yield await fetchBooks();
    await for (final Set<TableUpdate> _ in db.tableUpdates().where((Set<TableUpdate> updates) => updates.any((TableUpdate update) =>
        update.table == db.books.actualTableName ||
        update.table == db.bookAuthorsJoin.actualTableName ||
        update.table == db.bookTranslatorsJoin.actualTableName ||
        update.table == db.works.actualTableName ||
        update.table == db.sequenceVolumes.actualTableName))) {
      yield await fetchBooks();
    }
  }

  @override
  Future<void> addBook(BookModel book) async {
    await db.transaction(() async {
      await db.into(db.books).insertOnConflictUpdate(
        Book(
          id: book.id,
          title: book.title,
          compilationType: book.compilationType.name,
          isTranslation: book.isTranslation,
          toBeTranslated: book.toBeTranslated,
          cover: Images.compressImageIfNeeded(book.cover),
          language: book.language?.name,
          genre: book.genre?.name,
          isbn: book.isbn,
          publishedDate: book.publishedDate,
          noOfPages: book.noOfPages,
          originalTitle: book.originalTitle,
          originalLanguage: book.originalLanguage?.name,
          collectionStatus: book.collectionStatus.name,
          collectedDate: book.collectedDate,
          lendedDate: book.lendedDate,
          dueDate: book.dueDate,
          readingStatus: book.readingStatus.name,
          pausedPage: book.pausedPage,
          completedDate: book.completedDate,
          notes: book.notes,
          publisherId: book.publisherId,
          readerId: book.readerId,
          createdDate: book.createdDate,
          lastUpdated: book.lastUpdated,
        ).toCompanion(false),
      );

      // Sync Author Joins
      await (db.delete(db.bookAuthorsJoin)..where(($BookAuthorsJoinTable t) => t.bookId.equals(book.id))).go();
      for (final String authorId in book.authorIds) {
        await db.into(db.bookAuthorsJoin).insertOnConflictUpdate(
          BookAuthorsJoinCompanion.insert(bookId: book.id, authorId: authorId),
        );
      }

      // Sync Translator Joins
      await (db.delete(db.bookTranslatorsJoin)..where(($BookTranslatorsJoinTable t) => t.bookId.equals(book.id))).go();
      for (final String translatorId in book.translatorIds) {
        await db.into(db.bookTranslatorsJoin).insertOnConflictUpdate(
          BookTranslatorsJoinCompanion.insert(bookId: book.id, translatorId: translatorId),
        );
      }
    });
  }

  @override
  Future<void> editBook(BookModel book) async {
    await addBook(book); // SQLite insertOnConflictUpdate acts as clean upsert
  }

  @override
  Future<void> removeBook(String id) async {
    await db.transaction(() async {
      await (db.delete(db.books)..where(($BooksTable t) => t.id.equals(id))).go();
      await (db.delete(db.bookAuthorsJoin)..where(($BookAuthorsJoinTable t) => t.bookId.equals(id))).go();
      await (db.delete(db.bookTranslatorsJoin)..where(($BookTranslatorsJoinTable t) => t.bookId.equals(id))).go();
    });
  }

  @override
  Future<Map<String, dynamic>> scanBookCover(Uint8List imageBytes) async {
    const TextPart prompt = TextPart(
      'Return ONLY JSON. Analyze the image to see if it contains a book cover.\n\n'
      'RULES:\n'
      '1. VALIDATION: If the image is NOT a book cover, set "analysisError" to "The provided image does not appear to be a book cover."\n'
      '2. MULTIPLE COVERS: If there are multiple distinct book covers in the image, set "analysisError" to "Multiple book covers detected. Please scan only one book at a time."\n'
      '3. FORMATTING: All Names (Authors, Translators, Publishers) MUST use Title Case (e.g., "John Doe", not "JOHN DOE").\n'
      '4. NO DUMMY DATA: If fields like "isbn" are not clearly readable or appear as dummy text (like "N/A"), leave them as empty strings ("").\n'
      '5. LANGUAGE: For names (authorNames, translatorNames), provide them in the language they appear on the cover (e.g., Sinhala). If an English name is also present or commonly known for that person, provide it in the "otherName" field.\n'
      '6. UNCERTAINTY: If the book is not recognized with high certainty (>95%), provide OCR text in the corresponding fields instead of metadata.',
    );
    final Schema nameSchema = Schema.object(
      properties: <String, Schema>{
        'name': Schema.string(description: 'The name as it appears on the cover in Title Case'),
        'otherName': Schema.string(
          nullable: true,
          description: 'The English name or an alternative name in Title Case',
        ),
      },
    );
    final GenerativeModel model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.1-flash-lite',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: <String, Schema>{
            'analysisError': Schema.string(
              nullable: true,
              description: 'Error message if the image is invalid or contains multiple covers',
            ),
            'title': Schema.string(),
            'isTranslation': Schema.boolean(),
            'language': Schema.enumString(
              enumValues: Language.values.map((Language e) => e.name).toList(),
            ),
            'originalTitle': Schema.string(nullable: true),
            'originalLanguage': Schema.enumString(
              enumValues: OriginalLanguage.values.map((OriginalLanguage e) => e.name).toList(),
              nullable: true,
            ),
            'authorNames': Schema.array(items: nameSchema),
            'translatorNames': Schema.array(items: nameSchema),
            'publisher': nameSchema,
            'isbn': Schema.string(),
          },
        ),
      ),
    );
    final InlineDataPart imagePart = InlineDataPart('image/jpeg', imageBytes);
    final GenerateContentResponse response = await model.generateContent(<Content>[
      Content.multi(<Part>[prompt, imagePart]),
    ]);

    if (response.text == null) {
      throw Exception('Gemini returned an empty response.');
    }

    return jsonDecode(response.text!) as Map<String, dynamic>;
  }
}

@riverpod
BookRemoteDataSource bookRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return BookRemoteDataSourceImpl(db: db);
}
