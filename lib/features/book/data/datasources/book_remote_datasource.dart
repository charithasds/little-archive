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
    final SimpleSelectStatement<$BookCreatorsJoinTable, BookCreatorsJoinData> authorsQuery =
        db.select(db.bookCreatorsJoin)..where(
          ($BookCreatorsJoinTable t) =>
              t.bookId.equals(row.id) & t.role.equals(CreatorRole.author.name),
        );
    final List<BookCreatorsJoinData> authors = await authorsQuery.get();
    final List<String> authorIds = authors.map((BookCreatorsJoinData a) => a.creatorId).toList();

    final SimpleSelectStatement<$BookCreatorsJoinTable, BookCreatorsJoinData> translatorsQuery =
        db.select(db.bookCreatorsJoin)..where(
          ($BookCreatorsJoinTable t) =>
              t.bookId.equals(row.id) & t.role.equals(CreatorRole.translator.name),
        );
    final List<BookCreatorsJoinData> translators = await translatorsQuery.get();
    final List<String> translatorIds = translators
        .map((BookCreatorsJoinData t) => t.creatorId)
        .toList();

    // WorkIds: query work relation if applicable
    final SimpleSelectStatement<$WorksTable, Work> worksQuery = db.select(db.works)
      ..where(($WorksTable t) => t.bookId.equals(row.id));
    final List<Work> works = await worksQuery.get();
    final List<String> workIds = works.map((Work w) => w.id).toList();

    // SequenceVolumeIds: query sequence volume relation
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> volumesQuery = db.select(
      db.sequenceVolumes,
    )..where(($SequenceVolumesTable t) => t.bookId.equals(row.id));
    final List<SequenceVolume> volumes = await volumesQuery.get();
    final List<String> sequenceVolumeIds = volumes.map((SequenceVolume v) => v.id).toList();

    return BookModel(
      id: row.id,
      title: row.title,
      compilationType:
          CompilationType.values.asNameMap()[row.compilationType] ?? CompilationType.single,
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
      collectionStatus:
          CollectionStatus.values.asNameMap()[row.collectionStatus] ?? CollectionStatus.collected,
      collectedDate: row.collectedDate,
      lendedDate: row.lendedDate,
      dueDate: row.dueDate,
      readingStatus:
          ReadingStatus.values.asNameMap()[row.readingStatus] ?? ReadingStatus.notStarted,
      pausedPage: row.pausedPage,
      completedDate: row.completedDate,
      notes: row.notes,
      authorIds: authorIds,
      translatorIds: translatorIds,
      workIds: workIds,
      sequenceVolumeIds: sequenceVolumeIds,
      publisherId: row.publisherId,
      readerId: row.readerId,
      notForSale: row.notForSale,
      isSigned: row.isSigned,
      signedDate: row.signedDate,
      hasBookmark: row.hasBookmark,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );
  }

  @override
  Future<List<BookModel>> fetchBooks() async {
    final SimpleSelectStatement<$BooksTable, Book> query = db.select(db.books)
      ..orderBy(<OrderClauseGenerator<$BooksTable>>[
        ($BooksTable t) => OrderingTerm(expression: t.title),
      ]);
    final List<Book> rows = await query.get();
    final List<BookModel> books = <BookModel>[];
    for (final Book row in rows) {
      books.add(await _mapToBookModel(row));
    }
    return books;
  }

  @override
  Future<BookModel?> fetchBookById(String id) async {
    final SimpleSelectStatement<$BooksTable, Book> query = db.select(db.books)
      ..where(($BooksTable t) => t.id.equals(id));
    final Book? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToBookModel(row);
  }

  @override
  Stream<List<BookModel>> watchBooks() async* {
    yield await fetchBooks();
    await for (final Set<TableUpdate> _ in db.tableUpdates().where(
      (Set<TableUpdate> updates) => updates.any(
        (TableUpdate update) =>
            update.table == db.books.actualTableName ||
            update.table == db.bookCreatorsJoin.actualTableName ||
            update.table == db.works.actualTableName ||
            update.table == db.sequenceVolumes.actualTableName,
      ),
    )) {
      yield await fetchBooks();
    }
  }

  @override
  Future<void> addBook(BookModel book) async {
    await db.transaction(() async {
      await db
          .into(db.books)
          .insertOnConflictUpdate(
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
              notForSale: book.notForSale,
              isSigned: book.isSigned,
              signedDate: book.signedDate,
              hasBookmark: book.hasBookmark,
              createdDate: book.createdDate,
              lastUpdated: book.lastUpdated,
            ).toCompanion(false),
          );

      // Sync Creator Joins (Authors)
      await (db.delete(db.bookCreatorsJoin)..where(
            ($BookCreatorsJoinTable t) =>
                t.bookId.equals(book.id) & t.role.equals(CreatorRole.author.name),
          ))
          .go();
      for (final String authorId in book.authorIds) {
        await db
            .into(db.bookCreatorsJoin)
            .insertOnConflictUpdate(
              BookCreatorsJoinCompanion.insert(
                bookId: book.id,
                creatorId: authorId,
                role: CreatorRole.author,
              ),
            );
      }

      // Sync Creator Joins (Translators)
      await (db.delete(db.bookCreatorsJoin)..where(
            ($BookCreatorsJoinTable t) =>
                t.bookId.equals(book.id) & t.role.equals(CreatorRole.translator.name),
          ))
          .go();
      for (final String translatorId in book.translatorIds) {
        await db
            .into(db.bookCreatorsJoin)
            .insertOnConflictUpdate(
              BookCreatorsJoinCompanion.insert(
                bookId: book.id,
                creatorId: translatorId,
                role: CreatorRole.translator,
              ),
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
      await (db.delete(
        db.bookCreatorsJoin,
      )..where(($BookCreatorsJoinTable t) => t.bookId.equals(id))).go();
    });
  }

  @override
  Future<Map<String, dynamic>> scanBookCover(Uint8List imageBytes) async {
    const TextPart prompt = TextPart('''
You extract book metadata from a photo of a book cover. Return ONLY JSON matching the schema.

CORE RULE: Never guess. Every value must be (a) printed on the cover, (b) confirmed by a web search for this exact book, or (c) null / empty. A null is always better than a plausible-sounding invention. Never output placeholders such as "N/A", "Unknown", or "None".

STEP 1 - VALIDATE THE IMAGE
- If the image is not a book cover, set "analysisError" to "The provided image does not appear to be a book cover."
- Count DIFFERENT BOOKS, not different sides. The front and back cover (or spine) of the same book count as ONE book. A back cover usually has a blurb, reviews, a barcode, a price, and repeats the same title and author.
- Only if the image shows two or more different books (different titles/authors), set "analysisError" to "Multiple book covers detected. Please scan only one book at a time."
- If "analysisError" is set, leave all other fields null or empty.

STEP 2 - TITLE
1. Read the printed title, author, and publisher from the cover.
2. Search the web with them. If you find a confident match for the SAME book (same title and author), use the title as officially published, written in the language of the cover.
3. If there is no confident match, use the title exactly as printed on the cover (OCR). Do not autocorrect, complete, or translate it.
- The main title is the most prominent one. A smaller title in another language (for example an English title under a Sinhala title) is NOT a separate book.

STEP 3 - LANGUAGE
"language" is the language of the main title as printed on the cover. Ignore secondary or English subtitles when deciding.

STEP 4 - TRANSLATION
- "isTranslation" is true ONLY if the cover credits BOTH an author AND a translator (for example "translated by", "පරිවර්තනය", "மொழிபெயர்ப்பு").
- A bilingual title, an English subtitle, or a foreign-sounding author name is NOT evidence of translation.
- If false: "translatorNames" must be empty, and "originalTitle" and "originalLanguage" must be null.
- If true: fill "originalTitle" and "originalLanguage" from the cover or a confirmed web match; otherwise null.

STEP 5 - NAMES (authors, translators, publisher)
- Use Title Case ("John Doe", not "JOHN DOE"). Keep initials as printed ("R. L. Stine").
- Authors and translators are always separate lists; never put a translator in "authorNames".
- NOT a translation: authors are written in the same language as the book. "otherName" may hold the same name in a second language (for example the English form of a Sinhala name) only if it appears on the cover or you are certain from a web match.
- Translation: authors are written as printed on the cover. Translators are written in the language of this edition (the language the book was translated INTO), and "otherName" holds the other-language form.
- Never invent an "otherName". Use null if unsure.

STEP 6 - ISBN
- Return an ISBN only if its digits are actually printed on the cover (usually beside the barcode) or confirmed for this exact edition via search.
- Return the digits exactly as printed, with no hyphens or spaces. Do not convert or calculate check digits.
- If not clearly readable, return null.

STEP 7 - PUBLISHER
- Use only a publisher printed on the cover or confirmed for this edition. If not found, set "publisher" to null. Do not write "N/A" or "Unknown".

STEP 8 - UNCERTAINTY
If you are not highly certain about a value, prefer OCR text or null over recalled metadata.
''');

    final Schema nameSchema = Schema.object(
      properties: <String, Schema>{
        'name': Schema.string(description: 'Name as printed on the cover, Title Case'),
        'otherName': Schema.string(
          nullable: true,
          description: 'Same person in another language, only if known',
        ),
      },
    );

    final GenerativeModel model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
      generationConfig: GenerationConfig(
        temperature: 0,
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: <String, Schema>{
            'analysisError': Schema.string(nullable: true),
            'title': Schema.string(nullable: true),
            'isTranslation': Schema.boolean(),
            'language': Schema.enumString(
              enumValues: Language.values.map((Language e) => e.name).toList(),
              nullable: true,
            ),
            'originalTitle': Schema.string(nullable: true),
            'originalLanguage': Schema.enumString(
              enumValues: OriginalLanguage.values.map((OriginalLanguage e) => e.name).toList(),
              nullable: true,
            ),
            'authorNames': Schema.array(items: nameSchema),
            'translatorNames': Schema.array(items: nameSchema),
            'publisher': Schema.object(
              properties: <String, Schema>{
                'name': Schema.string(),
                'otherName': Schema.string(nullable: true),
              },
              nullable: true,
            ),
            'isbn': Schema.string(nullable: true),
          },
        ),
      ),
    );

    final GenerateContentResponse response = await model.generateContent(<Content>[
      Content.multi(<Part>[prompt, InlineDataPart('image/jpeg', imageBytes)]),
    ]);
    if (response.text == null) {
      throw Exception('Gemini returned an empty response.');
    }

    final Map<String, dynamic> result = jsonDecode(response.text!) as Map<String, dynamic>;
    return _sanitize(result);
  }
}

// Defensive cleanup for hallucinated placeholders and bad ISBNs.
Map<String, dynamic> _sanitize(Map<String, dynamic> r) {
  const Set<String> bad = <String>{'n/a', 'na', 'unknown', 'none', 'null', ''};
  bool isBad(String? s) => s == null || bad.contains(s.trim().toLowerCase());

  final Map<String, dynamic>? pub = r['publisher'] as Map<String, dynamic>?;
  if (pub == null || isBad(pub['name'] as String?)) {
    r['publisher'] = null;
  }

  r['isbn'] = _validIsbn13(r['isbn'] as String?);

  if (r['isTranslation'] != true) {
    r['translatorNames'] = <dynamic>[];
    r['originalTitle'] = null;
    r['originalLanguage'] = null;
  }
  return r;
}

String? _validIsbn13(String? raw) {
  if (raw == null) {
    return null;
  }
  String d = raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
  if (d.length == 10) {
    // convert ISBN-10 -> 13 in code, not in the model
    if (!RegExp(r'^\d{9}[\dX]$').hasMatch(d)) {
      return null;
    }
    final String core = '978${d.substring(0, 9)}';
    d = core + _isbn13Check(core).toString();
  }
  if (!RegExp(r'^\d{13}$').hasMatch(d)) {
    return null;
  }
  return _isbn13Check(d.substring(0, 12)) == int.parse(d[12]) ? d : null;
}

int _isbn13Check(String twelve) {
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    sum += int.parse(twelve[i]) * (i.isEven ? 1 : 3);
  }
  return (10 - sum % 10) % 10;
}

@riverpod
BookRemoteDataSource bookRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return BookRemoteDataSourceImpl(db: db);
}
