import '../datasources/publisher_remote_datasource.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../models/publisher_model.dart';

class PublisherRepositoryImpl implements PublisherRepository {
  final PublisherRemoteDataSource remoteDataSource;

  PublisherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PublisherEntity>> getPublishers() =>
      remoteDataSource.getPublishers();

  @override
  Future<PublisherEntity?> getPublisherById(String id) =>
      remoteDataSource.getPublisherById(id);

  @override
  Future<void> addPublisher(PublisherEntity publisher) {
    return remoteDataSource.addPublisher(
      PublisherModel(
        id: publisher.id,
        name: publisher.name,
        logo: publisher.logo,
        website: publisher.website,
        email: publisher.email,
        bookIds: publisher.bookIds,
      ),
    );
  }

  @override
  Future<void> updatePublisher(PublisherEntity publisher) {
    return remoteDataSource.updatePublisher(
      PublisherModel(
        id: publisher.id,
        name: publisher.name,
        logo: publisher.logo,
        website: publisher.website,
        email: publisher.email,
        bookIds: publisher.bookIds,
      ),
    );
  }

  @override
  Future<void> deletePublisher(String id) =>
      remoteDataSource.deletePublisher(id);

  @override
  Stream<List<PublisherEntity>> watchPublishers() =>
      remoteDataSource.watchPublishers();
}
