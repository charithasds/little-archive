import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/work_entity.dart';

abstract class WorkRepository {
  String generateId();
  Future<List<WorkEntity>> fetchWorks();
  Future<WorkEntity?> fetchWorkById(String id);
  Stream<List<WorkEntity>> watchWorks();
  Future<void> addWork(WorkEntity work, {WriteBatch? batch});
  Future<void> editWork(WorkEntity work, {WorkEntity? oldWork, WriteBatch? batch});
  Future<void> removeWork(String id, {WriteBatch? batch});
  Future<WorkEntity> upsertWork(
    WorkEntity work,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
    bool applyToBooks, {
    WriteBatch? batch,
  });
}
