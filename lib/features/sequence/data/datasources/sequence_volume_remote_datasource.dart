import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../models/sequence_volume_model.dart';

part 'sequence_volume_remote_datasource.g.dart';

abstract class SequenceVolumeRemoteDataSource {
  String generateId();

  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId);
  Future<SequenceVolumeModel?> fetchSequenceVolumeById(String id);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByBookId(String bookId);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByWorkId(String workId);
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId);
  Stream<List<SequenceVolumeModel>> watchAllSequenceVolumes();
  Future<void> addSequenceVolume(SequenceVolumeModel volume, {WriteBatch? batch});
  Future<void> editSequenceVolume(SequenceVolumeModel volume, {WriteBatch? batch});
  Future<void> removeSequenceVolume(String id, {WriteBatch? batch});
}

class SequenceVolumeRemoteDataSourceImpl implements SequenceVolumeRemoteDataSource {
  SequenceVolumeRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/sequence_volumes';

  @override
  String generateId() => firestoreService.generateId('sequence_volumes');

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(
          _firestore
              .collection(_collectionPath)
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
  Future<SequenceVolumeModel?> fetchSequenceVolumeById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      _firestore.collection(_collectionPath).doc(id),
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
          _firestore
              .collection(_collectionPath)
              .where('bookId', isEqualTo: bookId),
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
          _firestore
              .collection(_collectionPath)
              .where('workId', isEqualTo: workId),
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
      .collection(_collectionPath)
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
  Stream<List<SequenceVolumeModel>> watchAllSequenceVolumes() => _firestore
      .collection(_collectionPath)
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
        .collection(_collectionPath)
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
        .collection(_collectionPath)
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
        .collection(_collectionPath)
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
SequenceVolumeRemoteDataSource sequenceVolumeRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return SequenceVolumeRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}
