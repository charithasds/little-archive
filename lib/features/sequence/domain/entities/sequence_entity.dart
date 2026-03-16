import 'package:equatable/equatable.dart';

class SequenceEntity extends Equatable {
  const SequenceEntity({
    required this.id,

    required this.name,
    this.notes,
    required this.sequenceVolumeIds,
  });
  final String id;

  final String name;
  final String? notes;
  final List<String> sequenceVolumeIds;

  @override
  List<Object?> get props => <Object?>[id];

  SequenceEntity copyWith({
    String? id,
    String? name,
    String? notes,
    List<String>? sequenceVolumeIds,
  }) => SequenceEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
  );
}
