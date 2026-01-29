import '../entities/work_entity.dart';

abstract class WorkRepository {
  Future<List<WorkEntity>> getWorks(String userId);
  Future<WorkEntity?> getWorkById(String id);
  Future<void> addWork(WorkEntity work);
  Future<void> updateWork(WorkEntity work);
  Future<void> deleteWork(String id);
  Stream<List<WorkEntity>> watchWorks(String userId);
}
