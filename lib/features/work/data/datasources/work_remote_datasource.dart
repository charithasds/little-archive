import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String collectionPath = 'Works';

  FirebaseFirestore get firestore => firestoreService.instance;

  @override
  Future<List<WorkModel>> getWorks(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath).where('userId', isEqualTo: userId));
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
      firestore.collection(collectionPath).doc(id),
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
        .collection(collectionPath)
        .doc(work.id.isEmpty ? null : work.id)
        .set(work.toMap());
  }

  @override
  Future<void> updateWork(WorkModel work) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath).doc(work.id).update(work.toMap());
  }

  @override
  Future<void> deleteWork(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<WorkModel>> watchWorks(String userId) => firestore
      .collection(collectionPath)
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  WorkModel.fromMap(doc.data(), doc.id),
            )
            .toList());
}
