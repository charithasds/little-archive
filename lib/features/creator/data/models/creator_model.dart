import '../../domain/entities/creator_entity.dart';

class CreatorModel extends CreatorEntity {
  const CreatorModel({
    required super.id,
    required super.name,
    super.image,
    super.otherName,
    super.website,
    super.facebook,
    required super.authoredBookIds,
    required super.translatedBookIds,
    required super.authoredWorkIds,
    required super.translatedWorkIds,
    required super.createdDate,
    required super.lastUpdated,
  });

  factory CreatorModel.fromEntity(CreatorEntity entity) {
    if (entity is CreatorModel) {
      return entity;
    }
    return CreatorModel(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      otherName: entity.otherName,
      website: entity.website,
      facebook: entity.facebook,
      authoredBookIds: entity.authoredBookIds,
      translatedBookIds: entity.translatedBookIds,
      authoredWorkIds: entity.authoredWorkIds,
      translatedWorkIds: entity.translatedWorkIds,
      createdDate: entity.createdDate,
      lastUpdated: entity.lastUpdated,
    );
  }
}

String normalizeName(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[.\-_,]'), ' ') // "R. L. Stine" -> "r  l  stine"
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

// Match against BOTH name and otherName of existing creators, and both of the scanned name.
CreatorModel? findExistingCreator(Map<String, dynamic> scanned, List<CreatorModel> existing) {
  final Set<String> keys = <String>{
    normalizeName(scanned['name'] as String? ?? ''),
    if (scanned['otherName'] != null) normalizeName(scanned['otherName'] as String),
  }..remove('');
  for (final CreatorModel c in existing) {
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
