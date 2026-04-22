import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';

abstract class SequenceRepository {
  String generateId();

  Future<List<SequenceEntity>> fetchSequences();
  Future<SequenceEntity?> fetchSequenceById(String id);
  Stream<List<SequenceEntity>> watchSequences();
  Future<void> addSequence(SequenceEntity sequence);
  Future<void> editSequence(SequenceEntity sequence);
  Future<void> removeSequence(String id);

  String generateVolumeId();

  Future<List<SequenceVolumeEntity>> fetchSequenceVolumes(String sequenceId);
  Future<SequenceVolumeEntity?> fetchSequenceVolumeById(String id);
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByBookId(String bookId);
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByWorkId(String workId);
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(String sequenceId);
  Future<void> addSequenceVolume(SequenceVolumeEntity volume);
  Future<void> editSequenceVolume(SequenceVolumeEntity volume);
  Future<void> removeSequenceVolume(String id);
}
