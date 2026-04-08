import '../entities/reader_entity.dart';
import '../repositories/reader_repository.dart';

class GetReadersUseCase {
  const GetReadersUseCase(this.repository);
  final ReaderRepository repository;

  Future<List<ReaderEntity>> call(String userId) => repository.getReaders(userId);
}

class WatchReadersUseCase {
  const WatchReadersUseCase(this.repository);
  final ReaderRepository repository;

  Stream<List<ReaderEntity>> call(String userId) => repository.watchReaders(userId);
}

class GetReaderByIdUseCase {
  const GetReaderByIdUseCase(this.repository);
  final ReaderRepository repository;

  Future<ReaderEntity?> call(String id) => repository.getReaderById(id);
}

class AddReaderUseCase {
  const AddReaderUseCase(this.repository);
  final ReaderRepository repository;

  Future<void> call(ReaderEntity reader) => repository.addReader(reader);
}

class UpdateReaderUseCase {
  const UpdateReaderUseCase(this.repository);
  final ReaderRepository repository;

  Future<void> call(ReaderEntity reader) => repository.updateReader(reader);
}

class DeleteReaderUseCase {
  const DeleteReaderUseCase(this.repository);
  final ReaderRepository repository;

  Future<void> call(String id) => repository.deleteReader(id);
}
