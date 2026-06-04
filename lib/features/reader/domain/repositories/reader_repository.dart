import '../entities/reader_entity.dart';

abstract class ReaderRepository {
  String generateId();
  Future<List<ReaderEntity>> fetchReaders();
  Future<ReaderEntity?> fetchReaderById(String id);
  Stream<List<ReaderEntity>> watchReaders();
  Future<void> addReader(ReaderEntity reader);
  Future<void> editReader(ReaderEntity reader, {ReaderEntity? oldReader});
  Future<void> removeReader(String id);
}
