import '../datasources/reader_remote_datasource.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../models/reader_model.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  final ReaderRemoteDataSource remoteDataSource;

  ReaderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ReaderEntity>> getReaders() => remoteDataSource.getReaders();

  @override
  Future<ReaderEntity?> getReaderById(String id) =>
      remoteDataSource.getReaderById(id);

  @override
  Future<void> addReader(ReaderEntity reader) {
    return remoteDataSource.addReader(
      ReaderModel(
        id: reader.id,
        name: reader.name,
        image: reader.image,
        bookIds: reader.bookIds,
      ),
    );
  }

  @override
  Future<void> updateReader(ReaderEntity reader) {
    return remoteDataSource.updateReader(
      ReaderModel(
        id: reader.id,
        name: reader.name,
        image: reader.image,
        bookIds: reader.bookIds,
      ),
    );
  }

  @override
  Future<void> deleteReader(String id) => remoteDataSource.deleteReader(id);

  @override
  Stream<List<ReaderEntity>> watchReaders() => remoteDataSource.watchReaders();
}
