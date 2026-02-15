import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sequence_volume_entity.dart';

class SequenceVolumeModel extends SequenceVolumeEntity {
  const SequenceVolumeModel({
    required super.id,
    required super.userId,
    required super.volume,
    required super.sequenceId,
    super.bookId,
    super.workId,
    required super.createdDate,
    required super.lastUpdated,
  });

  factory SequenceVolumeModel.fromMap(Map<String, dynamic> map, String documentId) =>
      SequenceVolumeModel(
        id: documentId,
        userId: (map['userId'] as String?) ?? '',
        volume: (map['volume'] as String?) ?? '',
        sequenceId: (map['sequenceId'] as String?) ?? '',
        bookId: map['bookId'] as String?,
        workId: map['workId'] as String?,
        createdDate: (map['createdDate'] as Timestamp).toDate(),
        lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'volume': volume,
    'sequenceId': sequenceId,
    'bookId': bookId,
    'workId': workId,
    'createdDate': Timestamp.fromDate(createdDate),
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };
}
