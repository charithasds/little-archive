import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/author_entity.dart';

abstract class AuthorRepository {
  String generateId();
  Future<List<AuthorEntity>> fetchAuthors();
  Future<AuthorEntity?> fetchAuthorById(String id);
  Stream<List<AuthorEntity>> watchAuthors();
  Future<void> addAuthor(AuthorEntity author, {WriteBatch? batch});
  Future<void> editAuthor(AuthorEntity author, {AuthorEntity? oldAuthor, WriteBatch? batch});
  Future<void> removeAuthor(String id, {WriteBatch? batch});
}
