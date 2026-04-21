import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/reader_model.dart';

abstract class ReaderRemoteDataSource {
  String generateId();
  Future<List<ReaderModel>> fetchReaders();
  Future<ReaderModel?> fetchReaderById(String id);
  Stream<List<ReaderModel>> watchReaders();
  Future<void> addReader(ReaderModel reader);
  Future<void> editReader(ReaderModel reader);
  Future<void> removeReader(String id);
}

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  ReaderRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/readers';

  @override
  String generateId() => firestoreService.generateId('readers');

  @override
  Future<List<ReaderModel>> fetchReaders() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        await firestoreService.safeGetDocs(_firestore.collection(_collectionPath));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ReaderModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<ReaderModel?> fetchReaderById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc =
        await firestoreService.safeGetDoc(_firestore.collection(_collectionPath).doc(id));

    if (doc == null || !doc.exists) {
      return null;
    }

    return ReaderModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<ReaderModel>> watchReaders() => _firestore
      .collection(_collectionPath)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  ReaderModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<void> addReader(ReaderModel reader) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_collectionPath)
        .doc(reader.id.isEmpty ? null : reader.id)
        .set(reader.toMap());
  }

  @override
  Future<void> editReader(ReaderModel reader) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_collectionPath)
        .doc(reader.id)
        .update(reader.toMap());
  }

  @override
  Future<void> removeReader(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
