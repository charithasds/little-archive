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

  Map<String, dynamic> toMap() {
    return {
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

  factory SequenceVolumeModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return SequenceVolumeModel(
      id: documentId,
      userId: map['userId'] ?? '',
      volume: map['volume'] ?? '',
      sequenceId: map['sequenceId'] ?? '',
      bookId: map['bookId'],
      workId: map['workId'],
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
