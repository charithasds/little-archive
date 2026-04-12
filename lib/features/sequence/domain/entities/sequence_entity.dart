import 'package:equatable/equatable.dart';
import '../../../../core/shared/domain/utils/nullable.dart';

class SequenceEntity extends Equatable {
  const SequenceEntity({
    required this.id,
    required this.name,
    this.otherName,
    this.notes,
    required this.sequenceVolumeIds,
  });

  final String id;
  final String name;
  final String? otherName;
  final String? notes;
  final List<String> sequenceVolumeIds;

  @override
  List<Object?> get props => <Object?>[id];

  SequenceEntity copyWith({
    String? id,
    String? name,
    Nullable<String?>? otherName,
    Nullable<String?>? notes,
    List<String>? sequenceVolumeIds,
  }) => SequenceEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    otherName: otherName != null ? otherName.value : this.otherName,
    notes: notes != null ? notes.value : this.notes,
    sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
  );
}
