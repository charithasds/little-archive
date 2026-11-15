import 'dart:typed_data';

import '../../../sequence/domain/entities/sequence_entity.dart';
import '../entities/book_entity.dart';
import '../entities/scan/scanned_book_entity.dart';
import '../repositories/book_repository.dart';

class GenerateBookIdUseCase {
  const GenerateBookIdUseCase(this.repository);
  final BookRepository repository;

  String call() => repository.generateId();
}

class FetchBooksUseCase {
  const FetchBooksUseCase(this.repository);
  final BookRepository repository;

  Future<List<BookEntity>> call() => repository.fetchBooks();
}

class FetchBookByIdUseCase {
  const FetchBookByIdUseCase(this.repository);
  final BookRepository repository;

  Future<BookEntity?> call(String id) => repository.fetchBookById(id);
}

class WatchBooksUseCase {
  const WatchBooksUseCase(this.repository);
  final BookRepository repository;

  Stream<List<BookEntity>> call() => repository.watchBooks();
}

class AddBookUseCase {
  const AddBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book) => repository.addBook(book);
}

class EditBookUseCase {
  const EditBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book, {BookEntity? oldBook}) =>
      repository.editBook(book, oldBook: oldBook);
}

class RemoveBookUseCase {
  const RemoveBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(String id) => repository.removeBook(id);
}

class UpsertBookUseCase {
  const UpsertBookUseCase(this.repository);
  final BookRepository repository;

  Future<BookEntity> call({
    required BookEntity book,
    required Map<SequenceEntity, String> sequenceEntries,
    required bool isEdit,
    bool applyToWorks = false,
  }) => repository.upsertBook(
    book,
    sequenceEntries.map((SequenceEntity k, String v) => MapEntry<String, String>(k.id, v)),
    isEdit,
    applyToWorks,
  );
}

class ScanBookUseCase {
  const ScanBookUseCase(this.repository);
  final BookRepository repository;

  Future<ScannedBookEntity> call(Uint8List imageBytes) => repository.scanBookCover(imageBytes);
}
