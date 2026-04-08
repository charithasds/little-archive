import 'package:equatable/equatable.dart';

class SequenceEntity extends Equatable {
  const SequenceEntity({required this.id, required this.name, required this.sequenceVolumeIds});
  final String id;

  final String name;
  final List<String> sequenceVolumeIds;

  @override
  List<Object?> get props => <Object?>[id];

  SequenceEntity copyWith({String? id, String? name, List<String>? sequenceVolumeIds}) =>
      SequenceEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
      );
}
