import 'package:equatable/equatable.dart';

class SequenceEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? notes;
  final List<String> sequenceVolumeIds;

  const SequenceEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.notes,
    required this.sequenceVolumeIds,
  });

  @override
  List<Object?> get props => [id];
}
