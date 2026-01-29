import '../datasources/publisher_remote_datasource.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../models/publisher_model.dart';

class PublisherRepositoryImpl implements PublisherRepository {
  final PublisherRemoteDataSource remoteDataSource;

  PublisherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PublisherEntity>> getPublishers(String userId) =>
      remoteDataSource.getPublishers(userId);

  @override
  Future<PublisherEntity?> getPublisherById(String id) =>
      remoteDataSource.getPublisherById(id);

  @override
  Future<void> addPublisher(PublisherEntity publisher) {
    return remoteDataSource.addPublisher(
      PublisherModel(
        id: publisher.id,
        userId: publisher.userId,
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
  }

  @override
  Future<void> updatePublisher(PublisherEntity publisher) {
    return remoteDataSource.updatePublisher(
      PublisherModel(
        id: publisher.id,
        userId: publisher.userId,
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
  }

  @override
  Future<void> deletePublisher(String id) =>
      remoteDataSource.deletePublisher(id);

  @override
  Stream<List<PublisherEntity>> watchPublishers(String userId) =>
      remoteDataSource.watchPublishers(userId);
}
