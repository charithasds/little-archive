import '../../domain/entities/sequence_entity.dart';

class SequenceModel extends SequenceEntity {
  const SequenceModel({
    required super.id,
    required super.name,
    super.notes,
    required super.sequenceVolumeIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'sequenceVolumeIds': sequenceVolumeIds,
    };
  }

  factory SequenceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SequenceModel(
      id: documentId,
      name: map['name'] ?? '',
      notes: map['notes'],
      sequenceVolumeIds: List<String>.from(map['sequenceVolumeIds'] ?? []),
    );
  }
}
