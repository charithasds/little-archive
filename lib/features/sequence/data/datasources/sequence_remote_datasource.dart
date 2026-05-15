import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../models/sequence_model.dart';
import '../models/sequence_volume_model.dart';

part 'sequence_remote_datasource.g.dart';

abstract class SequenceRemoteDataSource {
  String generateSequenceId();
  String generateSequenceVolumeId();

  Future<List<SequenceModel>> fetchSequences();
  Future<SequenceModel?> fetchSequenceById(String id);
  Stream<List<SequenceModel>> watchSequences();
  Future<void> addSequence(SequenceModel sequence, {WriteBatch? batch});
  Future<void> editSequence(SequenceModel sequence, {WriteBatch? batch});
  Future<void> removeSequence(String id);

  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId);
  Future<SequenceVolumeModel?> fetchSequenceVolumeById(String id);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByBookId(String bookId);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByWorkId(String workId);
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId);
  Future<void> addSequenceVolume(SequenceVolumeModel volume, {WriteBatch? batch});
  Future<void> editSequenceVolume(SequenceVolumeModel volume, {WriteBatch? batch});
  Future<void> removeSequenceVolume(String id, {WriteBatch? batch});
}

class SequenceRemoteDataSourceImpl implements SequenceRemoteDataSource {
  SequenceRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _sequencesPath => 'users/$userId/sequences';
  String get _volumesPath => 'users/$userId/sequence_volumes';

  @override
  String generateSequenceId() => firestoreService.generateId('sequences');

  @override
  String generateSequenceVolumeId() => firestoreService.generateId('sequence_volumes');

  @override
  Future<List<SequenceModel>> fetchSequences() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(_firestore.collection(_sequencesPath).orderBy('name'));

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
      _firestore.collection(_sequencesPath).doc(id),
    );

    if (doc == null || !doc.exists) {
      return null;
    }

    return SequenceModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<SequenceModel>> watchSequences() => _firestore
      .collection(_sequencesPath)
      .orderBy('name')
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
  Future<void> addSequence(SequenceModel sequence, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_sequencesPath)
        .doc(sequence.id.isEmpty ? null : sequence.id);

    if (batch != null) {
      batch.set(docRef, sequence.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.set(sequence.toMap());
  }

  @override
  Future<void> editSequence(SequenceModel sequence, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_sequencesPath)
        .doc(sequence.id);

    if (batch != null) {
      batch.update(docRef, sequence.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.update(sequence.toMap());
  }

  @override
  Future<void> removeSequence(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_sequencesPath).doc(id).delete();
  }

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(
          _firestore.collection(_volumesPath).where('sequenceId', isEqualTo: sequenceId),
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
      _firestore.collection(_volumesPath).doc(id),
    );

    if (doc == null || !doc.exists) {
      return null;
    }

    return SequenceVolumeModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByBookId(String bookId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(_firestore.collection(_volumesPath).where('bookId', isEqualTo: bookId));

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
        .safeGetDocs(_firestore.collection(_volumesPath).where('workId', isEqualTo: workId));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              SequenceVolumeModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId) => _firestore
      .collection(_volumesPath)
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
  Future<void> addSequenceVolume(SequenceVolumeModel volume, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_volumesPath)
        .doc(volume.id.isEmpty ? null : volume.id);

    if (batch != null) {
      batch.set(docRef, volume.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.set(volume.toMap());
  }

  @override
  Future<void> editSequenceVolume(SequenceVolumeModel volume, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_volumesPath)
        .doc(volume.id);

    if (batch != null) {
      batch.update(docRef, volume.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.update(volume.toMap());
  }

  @override
  Future<void> removeSequenceVolume(String id, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_volumesPath)
        .doc(id);

    if (batch != null) {
      batch.delete(docRef);
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.delete();
  }
}

@riverpod
SequenceRemoteDataSource sequenceRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return SequenceRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}
