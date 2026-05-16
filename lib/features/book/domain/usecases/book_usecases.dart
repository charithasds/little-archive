import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../entities/book_entity.dart';
import '../entities/scan/scanned_book_entity.dart';
import '../repositories/book_repository.dart';

part 'book_usecases.g.dart';

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

  Future<void> call(BookEntity book) => repository.editBook(book);
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
    WriteBatch? batch,
  }) => repository.upsertBook(
    book,
    sequenceEntries.map((SequenceEntity k, String v) => MapEntry<String, String>(k.id, v)),
    isEdit,
    applyToWorks,
    batch: batch,
  );
}

class ScanBookUseCase {
  const ScanBookUseCase(this.repository);
  final BookRepository repository;

  Future<ScannedBookEntity> call(Uint8List imageBytes) => repository.scanBookCover(imageBytes);
}

@riverpod
GenerateBookIdUseCase generateBookIdUseCase(Ref ref) =>
    GenerateBookIdUseCase(ref.watch(bookRepositoryProvider));

@riverpod
FetchBooksUseCase fetchBooksUseCase(Ref ref) =>
    FetchBooksUseCase(ref.watch(bookRepositoryProvider));

@riverpod
FetchBookByIdUseCase fetchBookByIdUseCase(Ref ref) =>
    FetchBookByIdUseCase(ref.watch(bookRepositoryProvider));

@riverpod
WatchBooksUseCase watchBooksUseCase(Ref ref) =>
    WatchBooksUseCase(ref.watch(bookRepositoryProvider));

@riverpod
AddBookUseCase addBookUseCase(Ref ref) => AddBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
EditBookUseCase editBookUseCase(Ref ref) => EditBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
RemoveBookUseCase removeBookUseCase(Ref ref) =>
    RemoveBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
UpsertBookUseCase upsertBookUseCase(Ref ref) =>
    UpsertBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
ScanBookUseCase scanBookUseCase(Ref ref) => ScanBookUseCase(ref.watch(bookRepositoryProvider));
