import '../../domain/entities/sequence_entity.dart';

class SequenceModel extends SequenceEntity {
  const SequenceModel({
    required super.id,
    required super.name,
    super.notes,
    required super.sequenceVolumeIds,
    required super.createdDate,
    required super.lastUpdated,
  });
}
