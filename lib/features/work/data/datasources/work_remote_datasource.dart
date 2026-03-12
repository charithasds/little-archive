import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/work_model.dart';

abstract class WorkRemoteDataSource {
  Future<List<WorkModel>> getWorks(String userId);
  Future<WorkModel?> getWorkById(String id);
  Future<void> addWork(WorkModel work);
  Future<void> updateWork(WorkModel work);
  Future<void> deleteWork(String id);
  Stream<List<WorkModel>> watchWorks(String userId);
}

class WorkRemoteDataSourceImpl implements WorkRemoteDataSource {
  WorkRemoteDataSourceImpl({required this.firestoreService});
  final FirestoreService firestoreService;

  FirebaseFirestore get firestore => firestoreService.instance;

  String get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to perform this operation.');
    }
    return user.uid;
  }

  String collectionPath(String uid) => 'users/$uid/works';

  @override
  Future<List<WorkModel>> getWorks(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath(userId)));
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              WorkModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<WorkModel?> getWorkById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      firestore.collection(collectionPath(_currentUserId)).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return WorkModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addWork(WorkModel work) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(work.id.isEmpty ? null : work.id)
        .set(work.toMap());
  }

  @override
  Future<void> updateWork(WorkModel work) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(work.id).update(work.toMap());
  }

  @override
  Future<void> deleteWork(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(id).delete();
  }

  @override
  Stream<List<WorkModel>> watchWorks(String userId) => firestore
      .collection(collectionPath(userId))
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  WorkModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );
}
