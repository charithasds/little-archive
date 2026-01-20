import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sequence_model.dart';

abstract class SequenceRemoteDataSource {
  Future<List<SequenceModel>> getSequences();
  Future<SequenceModel?> getSequenceById(String id);
  Future<void> addSequence(SequenceModel sequence);
  Future<void> updateSequence(SequenceModel sequence);
  Future<void> deleteSequence(String id);
  Stream<List<SequenceModel>> watchSequences();
}

class SequenceRemoteDataSourceImpl implements SequenceRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'sequences';

  SequenceRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<SequenceModel>> getSequences() async {
    final snapshot = await firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => SequenceModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<SequenceModel?> getSequenceById(String id) async {
    final doc = await firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return SequenceModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addSequence(SequenceModel sequence) async {
    await firestore
        .collection(collectionPath)
        .doc(sequence.id.isEmpty ? null : sequence.id)
        .set(sequence.toMap());
  }

  @override
  Future<void> updateSequence(SequenceModel sequence) async {
    await firestore
        .collection(collectionPath)
        .doc(sequence.id)
        .update(sequence.toMap());
  }

  @override
  Future<void> deleteSequence(String id) async {
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<SequenceModel>> watchSequences() {
    return firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SequenceModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
