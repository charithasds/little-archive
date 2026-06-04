import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../datasources/publisher_remote_datasource.dart';
import '../models/publisher_model.dart';

part 'publisher_repository_impl.g.dart';

class PublisherRepositoryImpl implements PublisherRepository {
  PublisherRepositoryImpl({required this.remoteDataSource});

  final PublisherRemoteDataSource remoteDataSource;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<PublisherEntity>> fetchPublishers() => remoteDataSource.fetchPublishers();

  @override
  Future<PublisherEntity?> fetchPublisherById(String id) => remoteDataSource.fetchPublisherById(id);

  @override
  Stream<List<PublisherEntity>> watchPublishers() => remoteDataSource.watchPublishers();

  @override
  Future<void> addPublisher(PublisherEntity publisher) async {
    await remoteDataSource.addPublisher(
      PublisherModel(
        id: publisher.id,
        name: publisher.name,
        isSelfPublisher: publisher.isSelfPublisher,
        logo: publisher.logo,
        otherName: publisher.otherName,
        website: publisher.website,
        email: publisher.email,
        facebook: publisher.facebook,
        phoneNumber: publisher.phoneNumber,
        bookIds: publisher.bookIds,
        bookFairPublisherId: publisher.bookFairPublisherId,
        createdDate: publisher.createdDate,
        lastUpdated: publisher.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editPublisher(PublisherEntity publisher, {PublisherEntity? oldPublisher}) async {
    await remoteDataSource.editPublisher(
      PublisherModel(
        id: publisher.id,
        name: publisher.name,
        isSelfPublisher: publisher.isSelfPublisher,
        logo: publisher.logo,
        otherName: publisher.otherName,
        website: publisher.website,
        email: publisher.email,
        facebook: publisher.facebook,
        phoneNumber: publisher.phoneNumber,
        bookIds: publisher.bookIds,
        bookFairPublisherId: publisher.bookFairPublisherId,
        createdDate: publisher.createdDate,
        lastUpdated: publisher.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removePublisher(String id) async {
    await remoteDataSource.removePublisher(id);
  }
}

@riverpod
PublisherRepository publisherRepository(Ref ref) {
  final PublisherRemoteDataSource remoteDataSource = ref.watch(publisherRemoteDataSourceProvider);

  return PublisherRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
