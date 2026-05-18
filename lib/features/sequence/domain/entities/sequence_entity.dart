import 'package:equatable/equatable.dart';

import '../../../../core/shared/domain/utils/nullable.dart';

class SequenceEntity extends Equatable {
  const SequenceEntity({
    required this.id,
    required this.name,
    this.notes,
    required this.sequenceVolumeIds,
    required this.createdDate,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final String? notes;
  final List<String> sequenceVolumeIds;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];

  SequenceEntity copyWith({
    String? id,
    String? name,
    Nullable<String?>? notes,
    List<String>? sequenceVolumeIds,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => SequenceEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes != null ? notes.value : this.notes,
    sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
