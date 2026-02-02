import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_utils.dart';
import '../models/author_model.dart';

abstract class AuthorRemoteDataSource {
  Future<List<AuthorModel>> getAuthors(String userId);
  Future<AuthorModel?> getAuthorById(String id);
  Future<void> addAuthor(AuthorModel author);
  Future<void> updateAuthor(AuthorModel author);
  Future<void> deleteAuthor(String id);
  Stream<List<AuthorModel>> watchAuthors(String userId);
}

class AuthorRemoteDataSourceImpl implements AuthorRemoteDataSource {
  AuthorRemoteDataSourceImpl({required this.firestore});
  final FirebaseFirestore firestore;
  final String collectionPath = 'authors';

  @override
  Future<List<AuthorModel>> getAuthors(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await FirestoreUtils.safeGetDocs(
      firestore.collection(collectionPath).where('userId', isEqualTo: userId),
    );
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              AuthorModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<AuthorModel?> getAuthorById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await FirestoreUtils.safeGetDoc(
      firestore.collection(collectionPath).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return AuthorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addAuthor(AuthorModel author) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(author.id.isEmpty ? null : author.id)
        .set(author.toMap());
  }

  @override
  Future<void> updateAuthor(AuthorModel author) async {
    await FirestoreUtils.requireConnectivity();
    await firestore.collection(collectionPath).doc(author.id).update(author.toMap());
  }

  @override
  Future<void> deleteAuthor(String id) async {
    await FirestoreUtils.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<AuthorModel>> watchAuthors(String userId) {
    return firestore.collection(collectionPath).where('userId', isEqualTo: userId).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      return snapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                AuthorModel.fromMap(doc.data(), doc.id),
          )
          .toList();
    });
  }
}
