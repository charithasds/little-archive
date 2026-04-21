import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/sequence_model.dart';
import '../models/sequence_volume_model.dart';

abstract class SequenceRemoteDataSource {
  String generateId();
  Future<List<SequenceModel>> fetchSequences();
  Future<SequenceModel?> fetchSequenceById(String id);
  Stream<List<SequenceModel>> watchSequences();
  Future<void> addSequence(SequenceModel sequence);
  Future<void> editSequence(SequenceModel sequence);
  Future<void> removeSequence(String id);

  String generateVolumeId();
  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId);
  Future<SequenceVolumeModel?> fetchSequenceVolumeById(String id);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByBookId(String bookId);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByWorkId(String workId);
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId);
  Future<void> addSequenceVolume(SequenceVolumeModel volume);
  Future<void> editSequenceVolume(SequenceVolumeModel volume);
  Future<void> removeSequenceVolume(String id);
}

class SequenceRemoteDataSourceImpl implements SequenceRemoteDataSource {
  SequenceRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/sequences';
  String get _volumesCollectionPath => 'users/$userId/sequence_volumes';

  @override
  String generateId() => firestoreService.generateId('sequences');

  @override
  Future<List<SequenceModel>> fetchSequences() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(_firestore.collection(_collectionPath));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              SequenceModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<SequenceModel?> fetchSequenceById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      _firestore.collection(_collectionPath).doc(id),
    );

    if (doc == null || !doc.exists) {
      return null;
    }

    return SequenceModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<SequenceModel>> watchSequences() => _firestore
      .collection(_collectionPath)
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
  Future<void> addSequence(SequenceModel sequence) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_collectionPath)
        .doc(sequence.id.isEmpty ? null : sequence.id)
        .set(sequence.toMap());
  }

  @override
  Future<void> editSequence(SequenceModel sequence) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(sequence.id).update(sequence.toMap());
  }

  @override
  Future<void> removeSequence(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(id).delete();
  }

  @override
  String generateVolumeId() => firestoreService.generateId('sequence_volumes');

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(
          _firestore.collection(_volumesCollectionPath).where('sequenceId', isEqualTo: sequenceId),
        );

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              SequenceVolumeModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<SequenceVolumeModel?> fetchSequenceVolumeById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      _firestore.collection(_volumesCollectionPath).doc(id),
    );

    if (doc == null || !doc.exists) {
      return null;
    }

    return SequenceVolumeModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByBookId(String bookId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(
          _firestore.collection(_volumesCollectionPath).where('bookId', isEqualTo: bookId),
        );

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              SequenceVolumeModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByWorkId(String workId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(
          _firestore.collection(_volumesCollectionPath).where('workId', isEqualTo: workId),
        );

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              SequenceVolumeModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId) => _firestore
      .collection(_volumesCollectionPath)
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

  @override
  Future<void> addSequenceVolume(SequenceVolumeModel volume) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_volumesCollectionPath)
        .doc(volume.id.isEmpty ? null : volume.id)
        .set(volume.toMap());
  }

  @override
  Future<void> editSequenceVolume(SequenceVolumeModel volume) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_volumesCollectionPath).doc(volume.id).update(volume.toMap());
  }

  @override
  Future<void> removeSequenceVolume(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_volumesCollectionPath).doc(id).delete();
  }
}
