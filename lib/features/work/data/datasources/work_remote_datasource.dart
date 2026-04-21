import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/work_model.dart';

abstract class WorkRemoteDataSource {
  String generateId();

  Future<List<WorkModel>> fetchWorks();
  Future<WorkModel?> fetchWorkById(String id);
  Stream<List<WorkModel>> watchWorks();
  Future<void> addWork(WorkModel work);
  Future<void> editWork(WorkModel work);
  Future<void> removeWork(String id);
}

class WorkRemoteDataSourceImpl implements WorkRemoteDataSource {
  WorkRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/works';

  @override
  String generateId() => firestoreService.generateId('works');

  @override
  Future<List<WorkModel>> fetchWorks() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        await firestoreService.safeGetDocs(_firestore.collection(_collectionPath));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              WorkModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<WorkModel?> fetchWorkById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc =
        await firestoreService.safeGetDoc(_firestore.collection(_collectionPath).doc(id));

    if (doc == null || !doc.exists) {
      return null;
    }

    return WorkModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<WorkModel>> watchWorks() => _firestore
      .collection(_collectionPath)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  WorkModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<void> addWork(WorkModel work) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_collectionPath)
        .doc(work.id.isEmpty ? null : work.id)
        .set(work.toMap());
  }

  @override
  Future<void> editWork(WorkModel work) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(work.id).update(work.toMap());
  }

  @override
  Future<void> removeWork(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
