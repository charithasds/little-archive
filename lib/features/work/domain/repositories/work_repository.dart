import '../entities/work_entity.dart';

abstract class WorkRepository {
  String generateId();
  Future<List<WorkEntity>> fetchWorks();
  Future<WorkEntity?> fetchWorkById(String id);
  Stream<List<WorkEntity>> watchWorks();
  Future<void> addWork(WorkEntity work);
  Future<void> editWork(WorkEntity work, {WorkEntity? oldWork});
  Future<void> removeWork(String id);
  Future<WorkEntity> upsertWork(
    WorkEntity work,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
    bool applyToBooks,
  );
}
