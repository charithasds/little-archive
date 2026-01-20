import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/publisher_model.dart';

abstract class PublisherRemoteDataSource {
  Future<List<PublisherModel>> getPublishers();
  Future<PublisherModel?> getPublisherById(String id);
  Future<void> addPublisher(PublisherModel publisher);
  Future<void> updatePublisher(PublisherModel publisher);
  Future<void> deletePublisher(String id);
  Stream<List<PublisherModel>> watchPublishers();
}

class PublisherRemoteDataSourceImpl implements PublisherRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'publishers';

  PublisherRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PublisherModel>> getPublishers() async {
    final snapshot = await firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => PublisherModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<PublisherModel?> getPublisherById(String id) async {
    final doc = await firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return PublisherModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addPublisher(PublisherModel publisher) async {
    await firestore
        .collection(collectionPath)
        .doc(publisher.id.isEmpty ? null : publisher.id)
        .set(publisher.toMap());
  }

  @override
  Future<void> updatePublisher(PublisherModel publisher) async {
    await firestore
        .collection(collectionPath)
        .doc(publisher.id)
        .update(publisher.toMap());
  }

  @override
  Future<void> deletePublisher(String id) async {
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<PublisherModel>> watchPublishers() {
    return firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PublisherModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
