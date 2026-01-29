import '../../../../core/utils/firestore_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore firestore;
  final String collectionPath = 'books';

  BookRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<BookModel>> getBooks(String userId) async {
    final docs = await FirestoreUtils.safeGetDocs(
      firestore.collection(collectionPath).where('userId', isEqualTo: userId),
    );
    return docs.map((doc) => BookModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<BookModel?> getBookById(String id) async {
    final doc = await FirestoreUtils.safeGetDoc(
      firestore.collection(collectionPath).doc(id),
    );
    if (doc == null || !doc.exists) return null;
    return BookModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addBook(BookModel book) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(book.id.isEmpty ? null : book.id)
        .set(book.toMap());
  }

  @override
  Future<void> updateBook(BookModel book) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(book.id)
        .update(book.toMap());
  }

  @override
  Future<void> deleteBook(String id) async {
    await FirestoreUtils.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<BookModel>> watchBooks(String userId) {
    return firestore
        .collection(collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
