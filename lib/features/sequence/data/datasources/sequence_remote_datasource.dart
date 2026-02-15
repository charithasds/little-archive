import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String collectionPath = 'sequences';
  final String volumesCollectionPath = 'sequence_volumes';

  FirebaseFirestore get firestore => firestoreService.instance;

  @override
  Future<List<SequenceModel>> getSequences(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath).where('userId', isEqualTo: userId));
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
      firestore.collection(collectionPath).doc(id),
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
        .collection(collectionPath)
        .doc(sequence.id.isEmpty ? null : sequence.id)
        .set(sequence.toMap());
  }

  @override
  Future<void> updateSequence(SequenceModel sequence) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath).doc(sequence.id).update(sequence.toMap());
  }

  @override
  Future<void> deleteSequence(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<SequenceModel>> watchSequences(String userId) => firestore
      .collection(collectionPath)
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  SequenceModel.fromMap(doc.data(), doc.id),
            )
            .toList());

  @override
  Future<List<SequenceVolumeModel>> getSequenceVolumes(String sequenceId, String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(
          firestore
              .collection(volumesCollectionPath)
              .where('sequenceId', isEqualTo: sequenceId)
              .where('userId', isEqualTo: userId),
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
        .collection(volumesCollectionPath)
        .doc(volume.id.isEmpty ? null : volume.id)
        .set(volume.toMap());
  }

  @override
  Future<void> updateSequenceVolume(SequenceVolumeModel volume) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(volumesCollectionPath).doc(volume.id).update(volume.toMap());
  }

  @override
  Future<void> deleteSequenceVolume(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(volumesCollectionPath).doc(id).delete();
  }

  @override
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId, String userId) =>
      firestore
          .collection(volumesCollectionPath)
          .where('sequenceId', isEqualTo: sequenceId)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
                .map(
                  (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                      SequenceVolumeModel.fromMap(doc.data(), doc.id),
                )
                .toList());
}
