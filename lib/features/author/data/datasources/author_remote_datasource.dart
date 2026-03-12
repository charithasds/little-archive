import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
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
  AuthorRemoteDataSourceImpl({required this.firestoreService});
  final FirestoreService firestoreService;

  FirebaseFirestore get firestore => firestoreService.instance;

  String get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to perform this operation.');
    }
    return user.uid;
  }

  String collectionPath(String uid) => 'users/$uid/authors';

  @override
  Future<List<AuthorModel>> getAuthors(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath(userId)));
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              AuthorModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<AuthorModel?> getAuthorById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      firestore.collection(collectionPath(_currentUserId)).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return AuthorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addAuthor(AuthorModel author) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(author.id.isEmpty ? null : author.id)
        .set(author.toMap());
  }

  @override
  Future<void> updateAuthor(AuthorModel author) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(author.id)
        .update(author.toMap());
  }

  @override
  Future<void> deleteAuthor(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(id).delete();
  }

  @override
  Stream<List<AuthorModel>> watchAuthors(String userId) => firestore
      .collection(collectionPath(userId))
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  AuthorModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );
}
