import '../../../../core/utils/firestore_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/publisher_model.dart';

abstract class PublisherRemoteDataSource {
  Future<List<PublisherModel>> getPublishers(String userId);
  Future<PublisherModel?> getPublisherById(String id);
  Future<void> addPublisher(PublisherModel publisher);
  Future<void> updatePublisher(PublisherModel publisher);
  Future<void> deletePublisher(String id);
  Stream<List<PublisherModel>> watchPublishers(String userId);
}

class PublisherRemoteDataSourceImpl implements PublisherRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'publishers';

  PublisherRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PublisherModel>> getPublishers(String userId) async {
    final docs = await FirestoreUtils.safeGetDocs(
      firestore.collection(collectionPath).where('userId', isEqualTo: userId),
    );
    return docs
        .map((doc) => PublisherModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<PublisherModel?> getPublisherById(String id) async {
    final doc = await FirestoreUtils.safeGetDoc(
      firestore.collection(collectionPath).doc(id),
    );
    if (doc == null || !doc.exists) return null;
    return PublisherModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addPublisher(PublisherModel publisher) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(publisher.id.isEmpty ? null : publisher.id)
        .set(publisher.toMap());
  }

  @override
  Future<void> updatePublisher(PublisherModel publisher) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(publisher.id)
        .update(publisher.toMap());
  }

  @override
  Future<void> deletePublisher(String id) async {
    await FirestoreUtils.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<PublisherModel>> watchPublishers(String userId) {
    return firestore
        .collection(collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PublisherModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
