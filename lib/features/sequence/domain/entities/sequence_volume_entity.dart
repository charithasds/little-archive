import 'package:equatable/equatable.dart';

class SequenceVolumeEntity extends Equatable {
  const SequenceVolumeEntity({
    required this.id,

    required this.volume,
    required this.sequenceId,
    this.bookId,
    this.workId,
    required this.createdDate,
    required this.lastUpdated,
  });
  final String id;

  final String volume;
  final String sequenceId;
  final String? bookId;
  final String? workId;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];

  SequenceVolumeEntity copyWith({
    String? id,
    String? volume,
    String? sequenceId,
    String? bookId,
    String? workId,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => SequenceVolumeEntity(
    id: id ?? this.id,
    volume: volume ?? this.volume,
    sequenceId: sequenceId ?? this.sequenceId,
    bookId: bookId ?? this.bookId,
    workId: workId ?? this.workId,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
