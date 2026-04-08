import '../../domain/entities/sequence_entity.dart';

class SequenceModel extends SequenceEntity {
  const SequenceModel({required super.id, required super.name, required super.sequenceVolumeIds});

  factory SequenceModel.fromMap(Map<String, dynamic> map, String documentId) => SequenceModel(
    id: documentId,

    name: (map['name'] as String?) ?? '',
    sequenceVolumeIds: List<String>.from(
      map['sequenceVolumeIds'] as Iterable<dynamic>? ?? <String>[],
    ),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,

    'name': name,
    'sequenceVolumeIds': sequenceVolumeIds,
  };
}
