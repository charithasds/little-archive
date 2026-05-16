import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/sequence_entity.dart';

abstract class SequenceRepository {
  String generateId();
  Future<List<SequenceEntity>> fetchSequences();
  Future<SequenceEntity?> fetchSequenceById(String id);
  Stream<List<SequenceEntity>> watchSequences();
  Future<void> addSequence(SequenceEntity sequence, {WriteBatch? batch});
  Future<void> editSequence(SequenceEntity sequence, {WriteBatch? batch});
  Future<void> removeSequence(String id, {WriteBatch? batch});
}
