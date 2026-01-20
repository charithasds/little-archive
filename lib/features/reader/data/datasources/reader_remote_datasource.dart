import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reader_model.dart';

abstract class ReaderRemoteDataSource {
  Future<List<ReaderModel>> getReaders();
  Future<ReaderModel?> getReaderById(String id);
  Future<void> addReader(ReaderModel reader);
  Future<void> updateReader(ReaderModel reader);
  Future<void> deleteReader(String id);
  Stream<List<ReaderModel>> watchReaders();
}

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'readers';

  ReaderRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ReaderModel>> getReaders() async {
    final snapshot = await firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => ReaderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<ReaderModel?> getReaderById(String id) async {
    final doc = await firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return ReaderModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addReader(ReaderModel reader) async {
    await firestore
        .collection(collectionPath)
        .doc(reader.id.isEmpty ? null : reader.id)
        .set(reader.toMap());
  }

  @override
  Future<void> updateReader(ReaderModel reader) async {
    await firestore
        .collection(collectionPath)
        .doc(reader.id)
        .update(reader.toMap());
  }

  @override
  Future<void> deleteReader(String id) async {
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<ReaderModel>> watchReaders() {
    return firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ReaderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
