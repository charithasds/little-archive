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
    required super.workIds,
    required super.createdDate,
    required super.lastUpdated,
  });
}
