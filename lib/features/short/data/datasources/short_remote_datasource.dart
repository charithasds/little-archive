import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/short_model.dart';

abstract class ShortRemoteDataSource {
  Future<List<ShortModel>> getShorts();
  Future<ShortModel?> getShortById(String id);
  Future<void> addShort(ShortModel short);
  Future<void> updateShort(ShortModel short);
  Future<void> deleteShort(String id);
  Stream<List<ShortModel>> watchShorts();
}

class ShortRemoteDataSourceImpl implements ShortRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'shorts';

  ShortRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ShortModel>> getShorts() async {
    final snapshot = await firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => ShortModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<ShortModel?> getShortById(String id) async {
    final doc = await firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return ShortModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addShort(ShortModel short) async {
    await firestore
        .collection(collectionPath)
        .doc(short.id.isEmpty ? null : short.id)
        .set(short.toMap());
  }

  @override
  Future<void> updateShort(ShortModel short) async {
    await firestore
        .collection(collectionPath)
        .doc(short.id)
        .update(short.toMap());
  }

  @override
  Future<void> deleteShort(String id) async {
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<ShortModel>> watchShorts() {
    return firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ShortModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
