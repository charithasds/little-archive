import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/sequence_model.dart';
import '../models/sequence_volume_model.dart';

abstract class SequenceRemoteDataSource {
  Future<List<SequenceModel>> getSequences(String userId);
  Future<SequenceModel?> getSequenceById(String id);
  Future<void> addSequence(SequenceModel sequence);
  Future<void> updateSequence(SequenceModel sequence);
  Future<void> deleteSequence(String id);
  Stream<List<SequenceModel>> watchSequences(String userId);

  Future<List<SequenceVolumeModel>> getSequenceVolumes(String sequenceId, String userId);
  Future<void> addSequenceVolume(SequenceVolumeModel volume);
  Future<void> updateSequenceVolume(SequenceVolumeModel volume);
  Future<void> deleteSequenceVolume(String id);
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId, String userId);
}

class SequenceRemoteDataSourceImpl implements SequenceRemoteDataSource {
  SequenceRemoteDataSourceImpl({required this.firestoreService});
  final FirestoreService firestoreService;

  FirebaseFirestore get firestore => firestoreService.instance;

  String get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to perform this operation.');
    }
    return user.uid;
  }

  String collectionPath(String uid) => 'users/$uid/sequences';
  String volumesCollectionPath(String uid) => 'users/$uid/sequence_volumes';

  @override
  Future<List<SequenceModel>> getSequences(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath(userId)));
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              SequenceModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<SequenceModel?> getSequenceById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      firestore.collection(collectionPath(_currentUserId)).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return SequenceModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addSequence(SequenceModel sequence) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(sequence.id.isEmpty ? null : sequence.id)
        .set(sequence.toMap());
  }

  @override
  Future<void> updateSequence(SequenceModel sequence) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(sequence.id)
        .update(sequence.toMap());
  }

  @override
  Future<void> deleteSequence(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(id).delete();
  }

  @override
  Stream<List<SequenceModel>> watchSequences(String userId) => firestore
      .collection(collectionPath(userId))
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  SequenceModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<List<SequenceVolumeModel>> getSequenceVolumes(String sequenceId, String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(
          firestore
              .collection(volumesCollectionPath(userId))
              .where('sequenceId', isEqualTo: sequenceId),
        );
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              SequenceVolumeModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<void> addSequenceVolume(SequenceVolumeModel volume) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(volumesCollectionPath(_currentUserId))
        .doc(volume.id.isEmpty ? null : volume.id)
        .set(volume.toMap());
  }

  @override
  Future<void> updateSequenceVolume(SequenceVolumeModel volume) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(volumesCollectionPath(_currentUserId))
        .doc(volume.id)
        .update(volume.toMap());
  }

  @override
  Future<void> deleteSequenceVolume(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(volumesCollectionPath(_currentUserId)).doc(id).delete();
  }

  @override
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId, String userId) =>
      firestore
          .collection(volumesCollectionPath(userId))
          .where('sequenceId', isEqualTo: sequenceId)
          .snapshots()
          .map(
            (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
                .map(
                  (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                      SequenceVolumeModel.fromMap(doc.data(), doc.id),
                )
                .toList(),
          );
}
