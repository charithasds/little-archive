import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/reader_model.dart';

abstract class ReaderRemoteDataSource {
  Future<List<ReaderModel>> getReaders(String userId);
  Future<ReaderModel?> getReaderById(String id);
  Future<void> addReader(ReaderModel reader);
  Future<void> updateReader(ReaderModel reader);
  Future<void> deleteReader(String id);
  Stream<List<ReaderModel>> watchReaders(String userId);
}

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  ReaderRemoteDataSourceImpl({required this.firestoreService});
  final FirestoreService firestoreService;

  FirebaseFirestore get firestore => firestoreService.instance;

  String get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to perform this operation.');
    }
    return user.uid;
  }

  String collectionPath(String uid) => 'users/$uid/readers';

  @override
  Future<List<ReaderModel>> getReaders(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath(userId)));
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ReaderModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<ReaderModel?> getReaderById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      firestore.collection(collectionPath(_currentUserId)).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return ReaderModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addReader(ReaderModel reader) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(reader.id.isEmpty ? null : reader.id)
        .set(reader.toMap());
  }

  @override
  Future<void> updateReader(ReaderModel reader) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(reader.id)
        .update(reader.toMap());
  }

  @override
  Future<void> deleteReader(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(id).delete();
  }

  @override
  Stream<List<ReaderModel>> watchReaders(String userId) => firestore
      .collection(collectionPath(userId))
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  ReaderModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );
}
