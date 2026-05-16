import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/reader_entity.dart';

abstract class ReaderRepository {
  String generateId();
  Future<List<ReaderEntity>> fetchReaders();
  Future<ReaderEntity?> fetchReaderById(String id);
  Stream<List<ReaderEntity>> watchReaders();
  Future<void> addReader(ReaderEntity reader, {WriteBatch? batch});
  Future<void> editReader(ReaderEntity reader, {WriteBatch? batch});
  Future<void> removeReader(String id, {WriteBatch? batch});
}
