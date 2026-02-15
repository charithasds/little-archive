import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
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
  PublisherRemoteDataSourceImpl({required this.firestoreService});
  final FirestoreService firestoreService;
  final String collectionPath = 'publishers';

  FirebaseFirestore get firestore => firestoreService.instance;

  @override
  Future<List<PublisherModel>> getPublishers(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath).where('userId', isEqualTo: userId));
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              PublisherModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<PublisherModel?> getPublisherById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      firestore.collection(collectionPath).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return PublisherModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addPublisher(PublisherModel publisher) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(publisher.id.isEmpty ? null : publisher.id)
        .set(publisher.toMap());
  }

  @override
  Future<void> updatePublisher(PublisherModel publisher) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath).doc(publisher.id).update(publisher.toMap());
  }

  @override
  Future<void> deletePublisher(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<PublisherModel>> watchPublishers(String userId) => firestore
      .collection(collectionPath)
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  PublisherModel.fromMap(doc.data(), doc.id),
            )
            .toList());
}
