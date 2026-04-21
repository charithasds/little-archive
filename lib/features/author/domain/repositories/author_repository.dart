import '../entities/author_entity.dart';

abstract class AuthorRepository {
  String generateId();
  Future<List<AuthorEntity>> getAuthors();
  Future<AuthorEntity?> getAuthorById(String id);
  Stream<List<AuthorEntity>> watchAuthors();
  Future<void> addAuthor(AuthorEntity author);
  Future<void> editAuthor(AuthorEntity author);
  Future<void> removeAuthor(String id);
}
