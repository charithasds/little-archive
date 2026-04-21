import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  String generateId();
  Future<List<BookModel>> fetchBooks();
  Future<BookModel?> fetchBookById(String id);
  Stream<List<BookModel>> watchBooks();
  Future<void> addBook(BookModel book);
  Future<void> editBook(BookModel book);
  Future<void> removeBook(String id);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  BookRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/books';

  @override
  String generateId() => firestoreService.generateId('books');

  @override
  Future<List<BookModel>> fetchBooks() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        await firestoreService.safeGetDocs(_firestore.collection(_collectionPath));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              BookModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<BookModel?> fetchBookById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc =
        await firestoreService.safeGetDoc(_firestore.collection(_collectionPath).doc(id));

    if (doc == null || !doc.exists) {
      return null;
    }

    return BookModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<BookModel>> watchBooks() => _firestore
      .collection(_collectionPath)
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
  Future<void> addBook(BookModel book) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_collectionPath)
        .doc(book.id.isEmpty ? null : book.id)
        .set(book.toMap());
  }

  @override
  Future<void> editBook(BookModel book) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(book.id).update(book.toMap());
  }

  @override
  Future<void> removeBook(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
