import 'package:equatable/equatable.dart';

class SequenceVolumeEntity extends Equatable {

  const SequenceVolumeEntity({
    required this.id,
    required this.userId,
    required this.volume,
    required this.sequenceId,
    this.bookId,
    this.workId,
    required this.createdDate,
    required this.lastUpdated,
  });
  final String id;
  final String userId;
  final String volume;
  final String sequenceId;
  final String? bookId;
  final String? workId;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];
}
