import 'package:equatable/equatable.dart';

class TranslatorEntity extends Equatable {
  const TranslatorEntity({
    required this.id,

    required this.name,
    this.image,
    this.otherName,
    this.website,
    this.facebook,
    required this.bookIds,
    required this.workIds,
    required this.createdDate,
    required this.lastUpdated,
  });
  final String id;

  final String name;
  final String? image;
  final String? otherName;
  final String? website;
  final String? facebook;
  final List<String> bookIds;
  final List<String> workIds;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];

  TranslatorEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? otherName,
    String? website,
    String? facebook,
    List<String>? bookIds,
    List<String>? workIds,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => TranslatorEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    image: image ?? this.image,
    otherName: otherName ?? this.otherName,
    website: website ?? this.website,
    facebook: facebook ?? this.facebook,
    bookIds: bookIds ?? this.bookIds,
    workIds: workIds ?? this.workIds,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
