import 'package:equatable/equatable.dart';

import '../../../../domain/utils/nullable.dart';

class CreatorEntity extends Equatable {
  const CreatorEntity({
    required this.id,
    required this.name,
    this.image,
    this.otherName,
    this.website,
    this.facebook,
    required this.authoredBookIds,
    required this.translatedBookIds,
    required this.authoredWorkIds,
    required this.translatedWorkIds,
    required this.createdDate,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final String? image;
  final String? otherName;
  final String? website;
  final String? facebook;
  final List<String> authoredBookIds;
  final List<String> translatedBookIds;
  final List<String> authoredWorkIds;
  final List<String> translatedWorkIds;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id, lastUpdated];

  CreatorEntity copyWith({
    String? id,
    String? name,
    Nullable<String?>? image,
    Nullable<String?>? otherName,
    Nullable<String?>? website,
    Nullable<String?>? facebook,
    List<String>? authoredBookIds,
    List<String>? translatedBookIds,
    List<String>? authoredWorkIds,
    List<String>? translatedWorkIds,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => CreatorEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    image: image != null ? image.value : this.image,
    otherName: otherName != null ? otherName.value : this.otherName,
    website: website != null ? website.value : this.website,
    facebook: facebook != null ? facebook.value : this.facebook,
    authoredBookIds: authoredBookIds ?? this.authoredBookIds,
    translatedBookIds: translatedBookIds ?? this.translatedBookIds,
    authoredWorkIds: authoredWorkIds ?? this.authoredWorkIds,
    translatedWorkIds: translatedWorkIds ?? this.translatedWorkIds,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

String normalizeName(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[.\-_,]'), ' ') // "R. L. Stine" -> "r  l  stine"
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

// Match against BOTH name and otherName of existing creators, and both of the scanned name.
CreatorEntity? findExistingCreator(Map<String, dynamic> scanned, List<CreatorEntity> existing) {
  final Set<String> keys = <String>{
    normalizeName(scanned['name'] as String? ?? ''),
    if (scanned['otherName'] != null) normalizeName(scanned['otherName'] as String),
  }..remove('');
  for (final CreatorEntity c in existing) {
    final Set<String> candidate = <String>{
      normalizeName(c.name),
      if (c.otherName != null) normalizeName(c.otherName!),
    };
    if (candidate.intersection(keys).isNotEmpty) {
      return c;
    }
  }
  return null;
}
