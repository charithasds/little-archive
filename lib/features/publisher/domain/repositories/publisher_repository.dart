import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/publisher_entity.dart';

abstract class PublisherRepository {
  String generateId();
  Future<List<PublisherEntity>> fetchPublishers();
  Future<PublisherEntity?> fetchPublisherById(String id);
  Stream<List<PublisherEntity>> watchPublishers();
  Future<void> addPublisher(PublisherEntity publisher, {WriteBatch? batch});
  Future<void> editPublisher(PublisherEntity publisher, {PublisherEntity? oldPublisher, WriteBatch? batch});
  Future<void> removePublisher(String id, {WriteBatch? batch});
}
