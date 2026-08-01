import '../entities/creator_entity.dart';

abstract class CreatorRepository {
  String generateId();
  Future<List<CreatorEntity>> fetchCreators();
  Future<CreatorEntity?> fetchCreatorById(String id);
  Stream<List<CreatorEntity>> watchCreators();
  Future<void> addCreator(CreatorEntity creator);
  Future<void> editCreator(CreatorEntity creator, {CreatorEntity? oldCreator});
  Future<void> removeCreator(String id);
  Future<void> mergeCreators(String targetId, String sourceId);
}
