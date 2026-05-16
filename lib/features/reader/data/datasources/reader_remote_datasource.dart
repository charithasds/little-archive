import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../models/reader_model.dart';

part 'reader_remote_datasource.g.dart';

abstract class ReaderRemoteDataSource {
  String generateId();
  Future<List<ReaderModel>> fetchReaders();
  Future<ReaderModel?> fetchReaderById(String id);
  Stream<List<ReaderModel>> watchReaders();
  Future<void> addReader(ReaderModel reader, {WriteBatch? batch});
  Future<void> editReader(ReaderModel reader, {WriteBatch? batch});
  Future<void> removeReader(String id, {WriteBatch? batch});
}

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  ReaderRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/readers';

  @override
  String generateId() => firestoreService.generateId('readers');

  @override
  Future<List<ReaderModel>> fetchReaders() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(_firestore.collection(_collectionPath).orderBy('name'));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              ReaderModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<ReaderModel?> fetchReaderById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      _firestore.collection(_collectionPath).doc(id),
    );

    if (doc == null || !doc.exists) {
      return null;
    }

    return ReaderModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<ReaderModel>> watchReaders() => _firestore
      .collection(_collectionPath)
      .orderBy('name')
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  ReaderModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<void> addReader(ReaderModel reader, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collectionPath)
        .doc(reader.id.isEmpty ? null : reader.id);

    if (batch != null) {
      batch.set(docRef, reader.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.set(reader.toMap());
  }

  @override
  Future<void> editReader(ReaderModel reader, {WriteBatch? batch}) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collectionPath)
        .doc(reader.id);

    if (batch != null) {
      batch.update(docRef, reader.toMap());
      return;
    }

    await firestoreService.requireConnectivity();
    await docRef.update(reader.toMap());
  }

  @override
  Future<void> removeReader(String id, {WriteBatch? batch}) async {
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
ReaderRemoteDataSource readerRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return ReaderRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}
