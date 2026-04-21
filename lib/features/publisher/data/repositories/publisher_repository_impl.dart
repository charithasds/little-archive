import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../datasources/publisher_remote_datasource.dart';
import '../models/publisher_model.dart';

class PublisherRepositoryImpl implements PublisherRepository {
  PublisherRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});
  final PublisherRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<PublisherEntity>> getPublishers() => remoteDataSource.fetchPublishers();

  @override
  Future<PublisherEntity?> getPublisherById(String id) => remoteDataSource.fetchPublisherById(id);

  @override
  Stream<List<PublisherEntity>> watchPublishers() => remoteDataSource.watchPublishers();

  @override
  Future<void> addPublisher(PublisherEntity publisher) => remoteDataSource.addPublisher(
        PublisherModel(
          id: publisher.id,
          name: publisher.name,
          logo: publisher.logo,
          otherName: publisher.otherName,
          website: publisher.website,
          email: publisher.email,
          facebook: publisher.facebook,
          phoneNumber: publisher.phoneNumber,
          bookIds: publisher.bookIds,
          createdDate: publisher.createdDate,
          lastUpdated: publisher.lastUpdated,
        ),
      );

  @override
  Future<void> editPublisher(PublisherEntity publisher) => remoteDataSource.editPublisher(
        PublisherModel(
          id: publisher.id,
          name: publisher.name,
          logo: publisher.logo,
          otherName: publisher.otherName,
          website: publisher.website,
          email: publisher.email,
          facebook: publisher.facebook,
          phoneNumber: publisher.phoneNumber,
          bookIds: publisher.bookIds,
          createdDate: publisher.createdDate,
          lastUpdated: publisher.lastUpdated,
        ),
      );

  @override
  Future<void> removePublisher(String id) async {
    final PublisherModel? existingPublisher = await remoteDataSource.fetchPublisherById(id);

    if (existingPublisher != null) {
      await relationshipSyncService.removePublisherRelationships(
        publisherId: id,
        bookIds: existingPublisher.bookIds,
      );
    }

    await remoteDataSource.removePublisher(id);
  }
}
