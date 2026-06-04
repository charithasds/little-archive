import '../../domain/entities/sequence_volume_entity.dart';

class SequenceVolumeModel extends SequenceVolumeEntity {
  const SequenceVolumeModel({
    required super.id,
    required super.volume,
    required super.sequenceId,
    super.bookId,
    super.workId,
    required super.createdDate,
    required super.lastUpdated,
  });
}
