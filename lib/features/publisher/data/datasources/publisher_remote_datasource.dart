import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/publisher_model.dart';

abstract class PublisherRemoteDataSource {
  String generateId();

  Future<List<PublisherModel>> fetchPublishers();
  Future<PublisherModel?> fetchPublisherById(String id);
  Stream<List<PublisherModel>> watchPublishers();
  Future<void> addPublisher(PublisherModel publisher);
  Future<void> editPublisher(PublisherModel publisher);
  Future<void> removePublisher(String id);
}

class PublisherRemoteDataSourceImpl implements PublisherRemoteDataSource {
  PublisherRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/publishers';

  @override
  String generateId() => firestoreService.generateId('publishers');

  @override
  Future<List<PublisherModel>> fetchPublishers() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        await firestoreService.safeGetDocs(_firestore.collection(_collectionPath));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              PublisherModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<PublisherModel?> fetchPublisherById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc =
        await firestoreService.safeGetDoc(_firestore.collection(_collectionPath).doc(id));

    if (doc == null || !doc.exists) {
      return null;
    }

    return PublisherModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<PublisherModel>> watchPublishers() => _firestore
      .collection(_collectionPath)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  PublisherModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<void> addPublisher(PublisherModel publisher) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_collectionPath)
        .doc(publisher.id.isEmpty ? null : publisher.id)
        .set(publisher.toMap());
  }

  @override
  Future<void> editPublisher(PublisherModel publisher) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(publisher.id).update(publisher.toMap());
  }

  @override
  Future<void> removePublisher(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
