import '../entities/sequence_entity.dart';

abstract class SequenceRepository {
  Future<List<SequenceEntity>> getSequences();
  Future<SequenceEntity?> getSequenceById(String id);
  Future<void> addSequence(SequenceEntity sequence);
  Future<void> updateSequence(SequenceEntity sequence);
  Future<void> deleteSequence(String id);
  Stream<List<SequenceEntity>> watchSequences();
}
