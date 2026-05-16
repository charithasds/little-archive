import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../models/author_model.dart';

part 'author_remote_datasource.g.dart';

abstract class AuthorRemoteDataSource {
  String generateId();
  Future<List<AuthorModel>> fetchAuthors();
  Future<AuthorModel?> fetchAuthorById(String id);
  Stream<List<AuthorModel>> watchAuthors();
  Future<void> addAuthor(AuthorModel author, {WriteBatch? batch});
  Future<void> editAuthor(AuthorModel author, {WriteBatch? batch});
  Future<void> removeAuthor(String id, {WriteBatch? batch});
}

class AuthorRemoteDataSourceImpl implements AuthorRemoteDataSource {
  AuthorRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/authors';

  @override
  String generateId() => firestoreService.generateId('authors');

  @override
  Future<List<AuthorModel>> fetchAuthors() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(_firestore.collection(_collectionPath).orderBy('name'));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              AuthorModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<AuthorModel?> fetchAuthorById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      _firestore.collection(_collectionPath).doc(id),
    );

    if (doc == null || !doc.exists) {
      return null;
    }

    return AuthorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<AuthorModel>> watchAuthors() => _firestore
      .collection(_collectionPath)
      .orderBy('name')
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  AuthorModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<void> addAuthor(AuthorModel author, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collectionPath)
        .doc(author.id.isEmpty ? null : author.id);

    if (batch != null) {
      batch.set(docRef, author.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.set(author.toMap());
  }

  @override
  Future<void> editAuthor(AuthorModel author, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collectionPath)
        .doc(author.id);

    if (batch != null) {
      batch.update(docRef, author.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.update(author.toMap());
  }

  @override
  Future<void> removeAuthor(String id, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collectionPath)
        .doc(id);

    if (batch != null) {
      batch.delete(docRef);
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.delete();
  }
}

@riverpod
AuthorRemoteDataSource authorRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return AuthorRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}
