import '../../domain/entities/author_entity.dart';

class AuthorModel extends AuthorEntity {
  const AuthorModel({
    required super.id,
    required super.name,
    super.image,
    super.otherName,
    super.website,
    super.facebook,
    required super.bookIds,
    required super.shortIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'otherName': otherName,
      'website': website,
      'facebook': facebook,
      'bookIds': bookIds,
      'shortIds': shortIds,
    };
  }

  factory AuthorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AuthorModel(
      id: documentId,
      name: map['name'] ?? '',
      image: map['image'],
      otherName: map['otherName'],
      website: map['website'],
      facebook: map['facebook'],
      bookIds: List<String>.from(map['bookIds'] ?? []),
      shortIds: List<String>.from(map['shortIds'] ?? []),
    );
  }
}
