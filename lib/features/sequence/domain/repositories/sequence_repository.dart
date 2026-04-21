import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';

abstract class SequenceRepository {
  String generateId();

  Future<List<SequenceEntity>> getSequences();
  Future<SequenceEntity?> getSequenceById(String id);
  Stream<List<SequenceEntity>> watchSequences();
  Future<void> addSequence(SequenceEntity sequence);
  Future<void> editSequence(SequenceEntity sequence);
  Future<void> removeSequence(String id);

  String generateVolumeId();

  Future<List<SequenceVolumeEntity>> getSequenceVolumes(String sequenceId);
  Future<SequenceVolumeEntity?> getSequenceVolumeById(String id);
  Future<List<SequenceVolumeEntity>> getSequenceVolumesByBookId(String bookId);
  Future<List<SequenceVolumeEntity>> getSequenceVolumesByWorkId(String workId);
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(String sequenceId);
  Future<void> addSequenceVolume(SequenceVolumeEntity volume);
  Future<void> editSequenceVolume(SequenceVolumeEntity volume);
  Future<void> removeSequenceVolume(String id);
}
