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
