import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart' as local_lang;
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../models/book_model.dart';

part 'book_remote_datasource.g.dart';

abstract class BookRemoteDataSource {
  String generateId();
  Future<List<BookModel>> fetchBooks();
  Future<BookModel?> fetchBookById(String id);
  Stream<List<BookModel>> watchBooks();
  Future<void> addBook(BookModel book, {WriteBatch? batch});
  Future<void> editBook(BookModel book, {WriteBatch? batch});
  Future<void> removeBook(String id);
  Future<Map<String, dynamic>> scanBookCover(Uint8List imageBytes);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  BookRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/books';

  @override
  String generateId() => _firestore.collection(_collectionPath).doc().id;

  @override
  Future<List<BookModel>> fetchBooks() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(_firestore.collection(_collectionPath).orderBy('title'));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              BookModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<BookModel?> fetchBookById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      _firestore.collection(_collectionPath).doc(id),
    );

    if (doc == null || !doc.exists) {
      return null;
    }

    return BookModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<BookModel>> watchBooks() => _firestore
      .collection(_collectionPath)
      .orderBy('title')
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  BookModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<void> addBook(BookModel book, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collectionPath)
        .doc(book.id.isEmpty ? null : book.id);

    if (batch != null) {
      batch.set(docRef, book.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.set(book.toMap());
  }

  @override
  Future<void> editBook(BookModel book, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collectionPath)
        .doc(book.id);

    if (batch != null) {
      batch.update(docRef, book.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.update(book.toMap());
  }

  @override
  Future<void> removeBook(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(id).delete();
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
      '6. UNCERTAINTY: If the book is not recognized with high certainty (>99%), provide OCR text in the corresponding fields instead of metadata.',
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
      model: 'gemini-2.5-flash',
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
              enumValues: local_lang.Language.values
                  .map((local_lang.Language e) => e.name)
                  .toList(),
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
            'genre': Schema.enumString(enumValues: Genre.values.map((Genre e) => e.name).toList()),
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
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return BookRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}
