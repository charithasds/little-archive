import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks(String userId);
  Future<BookModel?> getBookById(String id);
  Future<void> addBook(BookModel book);
  Future<void> updateBook(BookModel book);
  Future<void> deleteBook(String id);
  Stream<List<BookModel>> watchBooks(String userId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  BookRemoteDataSourceImpl({required this.firestoreService});
  final FirestoreService firestoreService;

  FirebaseFirestore get firestore => firestoreService.instance;

  String get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to perform this operation.');
    }
    return user.uid;
  }

  String collectionPath(String uid) => 'users/$uid/books';

  @override
  Future<List<BookModel>> getBooks(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath(userId)));
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              BookModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<BookModel?> getBookById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      firestore.collection(collectionPath(_currentUserId)).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return BookModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addBook(BookModel book) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(book.id.isEmpty ? null : book.id)
        .set(book.toMap());
  }

  @override
  Future<void> updateBook(BookModel book) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(book.id).update(book.toMap());
  }

  @override
  Future<void> deleteBook(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(id).delete();
  }

  @override
  Stream<List<BookModel>> watchBooks(String userId) => firestore
      .collection(collectionPath(userId))
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  BookModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );
}
