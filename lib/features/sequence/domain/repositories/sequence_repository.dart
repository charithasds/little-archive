import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';

abstract class SequenceRepository {
  // Sequence methods
  Future<List<SequenceEntity>> getSequences(String userId);
  Future<SequenceEntity?> getSequenceById(String id);
  Future<void> addSequence(SequenceEntity sequence);
  Future<void> updateSequence(SequenceEntity sequence);
  Future<void> deleteSequence(String id);
  Stream<List<SequenceEntity>> watchSequences(String userId);

  // SequenceVolume methods
  Future<List<SequenceVolumeEntity>> getSequenceVolumes(
    String sequenceId,
    String userId,
  );
  Future<void> addSequenceVolume(SequenceVolumeEntity volume);
  Future<void> updateSequenceVolume(SequenceVolumeEntity volume);
  Future<void> deleteSequenceVolume(String id);
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(
    String sequenceId,
    String userId,
  );
}
