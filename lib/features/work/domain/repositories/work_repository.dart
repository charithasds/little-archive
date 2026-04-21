import '../entities/work_entity.dart';

abstract class WorkRepository {
  String generateId();

  Future<List<WorkEntity>> getWorks();
  Future<WorkEntity?> getWorkById(String id);
  Stream<List<WorkEntity>> watchWorks();
  Future<void> addWork(WorkEntity work);
  Future<void> editWork(WorkEntity work);
  Future<void> removeWork(String id);
}
