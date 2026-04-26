import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/reader_repository_impl.dart';
import '../entities/reader_entity.dart';
import '../repositories/reader_repository.dart';

part 'reader_usecases.g.dart';

class GenerateReaderIdUseCase {
  const GenerateReaderIdUseCase(this.repository);
  final ReaderRepository repository;

  String call() => repository.generateId();
}

class FetchReadersUseCase {
  const FetchReadersUseCase(this.repository);
  final ReaderRepository repository;

  Future<List<ReaderEntity>> call() => repository.fetchReaders();
}

class FetchReaderByIdUseCase {
  const FetchReaderByIdUseCase(this.repository);
  final ReaderRepository repository;

  Future<ReaderEntity?> call(String id) => repository.fetchReaderById(id);
}

class WatchReadersUseCase {
  const WatchReadersUseCase(this.repository);
  final ReaderRepository repository;

  Stream<List<ReaderEntity>> call() => repository.watchReaders();
}

class FetchReaderCountUseCase {
  const FetchReaderCountUseCase(this.repository);
  final ReaderRepository repository;

  Future<int> call() => repository.fetchCount();
}

class AddReaderUseCase {
  const AddReaderUseCase(this.repository);
  final ReaderRepository repository;

  Future<void> call(ReaderEntity reader) => repository.addReader(reader);
}

class EditReaderUseCase {
  const EditReaderUseCase(this.repository);
  final ReaderRepository repository;

  Future<void> call(ReaderEntity reader) => repository.editReader(reader);
}

class RemoveReaderUseCase {
  const RemoveReaderUseCase(this.repository);
  final ReaderRepository repository;

  Future<void> call(String id) => repository.removeReader(id);
}

@riverpod
GenerateReaderIdUseCase generateReaderIdUseCase(Ref ref) =>
    GenerateReaderIdUseCase(ref.watch(readerRepositoryProvider));

@riverpod
FetchReadersUseCase fetchReadersUseCase(Ref ref) =>
    FetchReadersUseCase(ref.watch(readerRepositoryProvider));

@riverpod
FetchReaderByIdUseCase fetchReaderByIdUseCase(Ref ref) =>
    FetchReaderByIdUseCase(ref.watch(readerRepositoryProvider));

@riverpod
WatchReadersUseCase watchReadersUseCase(Ref ref) =>
    WatchReadersUseCase(ref.watch(readerRepositoryProvider));

@riverpod
FetchReaderCountUseCase fetchReaderCountUseCase(Ref ref) =>
    FetchReaderCountUseCase(ref.watch(readerRepositoryProvider));

@riverpod
AddReaderUseCase addReaderUseCase(Ref ref) => AddReaderUseCase(ref.watch(readerRepositoryProvider));

@riverpod
EditReaderUseCase editReaderUseCase(Ref ref) =>
    EditReaderUseCase(ref.watch(readerRepositoryProvider));

@riverpod
RemoveReaderUseCase removeReaderUseCase(Ref ref) =>
    RemoveReaderUseCase(ref.watch(readerRepositoryProvider));
