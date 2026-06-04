import '../entities/sequence_entity.dart';

abstract class SequenceRepository {
  String generateId();
  Future<List<SequenceEntity>> fetchSequences();
  Future<SequenceEntity?> fetchSequenceById(String id);
  Stream<List<SequenceEntity>> watchSequences();
  Future<void> addSequence(SequenceEntity sequence);
  Future<void> editSequence(SequenceEntity sequence, {SequenceEntity? oldSequence});
  Future<void> removeSequence(String id);
}
