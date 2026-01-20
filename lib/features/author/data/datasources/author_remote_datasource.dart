import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/author_model.dart';

abstract class AuthorRemoteDataSource {
  Future<List<AuthorModel>> getAuthors();
  Future<AuthorModel?> getAuthorById(String id);
  Future<void> addAuthor(AuthorModel author);
  Future<void> updateAuthor(AuthorModel author);
  Future<void> deleteAuthor(String id);
  Stream<List<AuthorModel>> watchAuthors();
}

class AuthorRemoteDataSourceImpl implements AuthorRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'authors';

  AuthorRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AuthorModel>> getAuthors() async {
    final snapshot = await firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => AuthorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<AuthorModel?> getAuthorById(String id) async {
    final doc = await firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return AuthorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addAuthor(AuthorModel author) async {
    await firestore
        .collection(collectionPath)
        .doc(author.id.isEmpty ? null : author.id)
        .set(author.toMap());
  }

  @override
  Future<void> updateAuthor(AuthorModel author) async {
    await firestore
        .collection(collectionPath)
        .doc(author.id)
        .update(author.toMap());
  }

  @override
  Future<void> deleteAuthor(String id) async {
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<AuthorModel>> watchAuthors() {
    return firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AuthorModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
