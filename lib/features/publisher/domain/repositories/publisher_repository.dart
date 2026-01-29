import '../entities/publisher_entity.dart';

abstract class PublisherRepository {
  Future<List<PublisherEntity>> getPublishers(String userId);
  Future<PublisherEntity?> getPublisherById(String id);
  Future<void> addPublisher(PublisherEntity publisher);
  Future<void> updatePublisher(PublisherEntity publisher);
  Future<void> deletePublisher(String id);
  Stream<List<PublisherEntity>> watchPublishers(String userId);
}
