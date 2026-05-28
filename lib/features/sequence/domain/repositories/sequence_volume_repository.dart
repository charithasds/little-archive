import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/sequence_volume_entity.dart';

abstract class SequenceVolumeRepository {
  String generateId();
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumes(String sequenceId);
  Future<SequenceVolumeEntity?> fetchSequenceVolumeById(String id);
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByBookId(String bookId);
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByWorkId(String workId);
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(String sequenceId);
  Stream<List<SequenceVolumeEntity>> watchAllSequenceVolumes();
  Future<void> addSequenceVolume(SequenceVolumeEntity volume, {WriteBatch? batch});
  Future<void> editSequenceVolume(SequenceVolumeEntity volume, {SequenceVolumeEntity? oldVolume, WriteBatch? batch});
  Future<void> removeSequenceVolume(String id, {WriteBatch? batch});
  Future<List<String>> syncBookVolumes(
    String bookId,
    Map<String, String> sequenceIdToVolume,
    bool isEdit, {
    WriteBatch? batch,
  });
  Future<List<String>> syncWorkVolumes(
    String workId,
    Map<String, String> sequenceIdToVolume,
    bool isEdit, {
    WriteBatch? batch,
  });
}
