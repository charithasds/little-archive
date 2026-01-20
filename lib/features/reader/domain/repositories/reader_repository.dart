import '../entities/reader_entity.dart';

abstract class ReaderRepository {
  Future<List<ReaderEntity>> getReaders();
  Future<ReaderEntity?> getReaderById(String id);
  Future<void> addReader(ReaderEntity reader);
  Future<void> updateReader(ReaderEntity reader);
  Future<void> deleteReader(String id);
  Stream<List<ReaderEntity>> watchReaders();
}
