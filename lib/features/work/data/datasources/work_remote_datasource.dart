import '../../../../core/utils/firestore_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore firestore;
  final String collectionPath = 'Works';

  WorkRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<WorkModel>> getWorks(String userId) async {
    final docs = await FirestoreUtils.safeGetDocs(
      firestore.collection(collectionPath).where('userId', isEqualTo: userId),
    );
    return docs.map((doc) => WorkModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<WorkModel?> getWorkById(String id) async {
    final doc = await FirestoreUtils.safeGetDoc(
      firestore.collection(collectionPath).doc(id),
    );
    if (doc == null || !doc.exists) return null;
    return WorkModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addWork(WorkModel work) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(work.id.isEmpty ? null : work.id)
        .set(work.toMap());
  }

  @override
  Future<void> updateWork(WorkModel work) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(work.id)
        .update(work.toMap());
  }

  @override
  Future<void> deleteWork(String id) async {
    await FirestoreUtils.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<WorkModel>> watchWorks(String userId) {
    return firestore
        .collection(collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WorkModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
