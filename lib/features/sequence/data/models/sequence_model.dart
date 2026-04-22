import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sequence_entity.dart';

class SequenceModel extends SequenceEntity {
  const SequenceModel({
    required super.id,
    required super.name,
    super.otherName,
    super.notes,
    required super.sequenceVolumeIds,
    required super.createdDate,
    required super.lastUpdated,
  });

  factory SequenceModel.fromMap(Map<String, dynamic> map, String documentId) => SequenceModel(
    id: documentId,
    name: (map['name'] as String?) ?? '',
    otherName: map['otherName'] as String?,
    notes: map['notes'] as String?,
    sequenceVolumeIds: List<String>.from(
      map['sequenceVolumeIds'] as Iterable<dynamic>? ?? <String>[],
    ),
    createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'otherName': otherName,
    'notes': notes,
    'sequenceVolumeIds': sequenceVolumeIds,
    'createdDate': Timestamp.fromDate(createdDate),
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };
}
