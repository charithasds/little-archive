import '../entities/reader_entity.dart';

abstract class ReaderRepository {
  String generateId();
  Future<List<ReaderEntity>> getReaders(String userId);
  Future<ReaderEntity?> getReaderById(String id);
  Future<void> addReader(ReaderEntity reader);
  Future<void> updateReader(ReaderEntity reader);
  Future<void> deleteReader(String id);
  Stream<List<ReaderEntity>> watchReaders(String userId);
}
