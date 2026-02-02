import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_utils.dart';
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

  ReaderRemoteDataSourceImpl({required this.firestore});
  final FirebaseFirestore firestore;
  final String collectionPath = 'readers';

  @override
  Future<List<ReaderModel>> getReaders(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await FirestoreUtils.safeGetDocs(
      firestore.collection(collectionPath).where('userId', isEqualTo: userId),
    );
    return docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ReaderModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<ReaderModel?> getReaderById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await FirestoreUtils.safeGetDoc(
      firestore.collection(collectionPath).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return ReaderModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addReader(ReaderModel reader) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(reader.id.isEmpty ? null : reader.id)
        .set(reader.toMap());
  }

  @override
  Future<void> updateReader(ReaderModel reader) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(reader.id)
        .update(reader.toMap());
  }

  @override
  Future<void> deleteReader(String id) async {
    await FirestoreUtils.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<ReaderModel>> watchReaders(String userId) {
    return firestore
        .collection(collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ReaderModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
