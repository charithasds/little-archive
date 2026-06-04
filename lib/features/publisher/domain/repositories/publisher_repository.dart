import '../entities/publisher_entity.dart';

abstract class PublisherRepository {
  String generateId();
  Future<List<PublisherEntity>> fetchPublishers();
  Future<PublisherEntity?> fetchPublisherById(String id);
  Stream<List<PublisherEntity>> watchPublishers();
  Future<void> addPublisher(PublisherEntity publisher);
  Future<void> editPublisher(PublisherEntity publisher, {PublisherEntity? oldPublisher});
  Future<void> removePublisher(String id);
}
