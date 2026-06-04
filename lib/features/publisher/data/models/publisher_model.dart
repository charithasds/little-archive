import '../../domain/entities/publisher_entity.dart';

class PublisherModel extends PublisherEntity {
  const PublisherModel({
    required super.id,
    required super.name,
    required super.isSelfPublisher,
    super.logo,
    super.otherName,
    super.website,
    super.email,
    super.facebook,
    super.phoneNumber,
    required super.bookIds,
    super.bookFairPublisherId,
    required super.createdDate,
    required super.lastUpdated,
  });
}
