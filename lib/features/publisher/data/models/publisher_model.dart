import '../../domain/entities/publisher_entity.dart';

class PublisherModel extends PublisherEntity {
  const PublisherModel({
    required super.id,
    required super.name,
    super.logo,
    super.website,
    super.email,
    required super.bookIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'website': website,
      'email': email,
      'bookIds': bookIds,
    };
  }

  factory PublisherModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PublisherModel(
      id: documentId,
      name: map['name'] ?? '',
      logo: map['logo'],
      website: map['website'],
      email: map['email'],
      bookIds: List<String>.from(map['bookIds'] ?? []),
    );
  }
}
