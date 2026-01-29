import '../entities/author_entity.dart';

abstract class AuthorRepository {
  Future<List<AuthorEntity>> getAuthors(String userId);
  Future<AuthorEntity?> getAuthorById(String id);
  Future<void> addAuthor(AuthorEntity author);
  Future<void> updateAuthor(AuthorEntity author);
  Future<void> deleteAuthor(String id);
  Stream<List<AuthorEntity>> watchAuthors(String userId);
}
