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
}
