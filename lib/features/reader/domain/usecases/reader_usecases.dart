import '../entities/reader_entity.dart';
import '../repositories/reader_repository.dart';

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
