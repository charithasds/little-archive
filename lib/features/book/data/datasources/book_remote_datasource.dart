import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks();
  Future<BookModel?> getBookById(String id);
  Future<void> addBook(BookModel book);
  Future<void> updateBook(BookModel book);
  Future<void> deleteBook(String id);
  Stream<List<BookModel>> watchBooks();
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'books';

  BookRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<BookModel>> getBooks() async {
    final snapshot = await firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => BookModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<BookModel?> getBookById(String id) async {
    final doc = await firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return BookModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addBook(BookModel book) async {
    await firestore
        .collection(collectionPath)
        .doc(book.id.isEmpty ? null : book.id)
        .set(book.toMap());
  }

  @override
  Future<void> updateBook(BookModel book) async {
    await firestore
        .collection(collectionPath)
        .doc(book.id)
        .update(book.toMap());
  }

  @override
  Future<void> deleteBook(String id) async {
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<BookModel>> watchBooks() {
    return firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
