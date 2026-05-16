import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../datasources/publisher_remote_datasource.dart';
import '../models/publisher_model.dart';

part 'publisher_repository_impl.g.dart';

class PublisherRepositoryImpl implements PublisherRepository {
  PublisherRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});

  final PublisherRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<PublisherEntity>> fetchPublishers() => remoteDataSource.fetchPublishers();

  @override
  Future<PublisherEntity?> fetchPublisherById(String id) => remoteDataSource.fetchPublisherById(id);

  @override
  Stream<List<PublisherEntity>> watchPublishers() => remoteDataSource.watchPublishers();

  @override
  Future<void> addPublisher(PublisherEntity publisher, {WriteBatch? batch}) async {
    await remoteDataSource.addPublisher(
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
      batch: batch,
    );

    await relationshipSyncService.syncPublisherRelationships(
      publisherId: publisher.id,
      newBookIds: publisher.bookIds,
      batch: batch,
    );
  }

  @override
  Future<void> editPublisher(PublisherEntity publisher, {WriteBatch? batch}) async {
    final PublisherModel? existingPublisher = await remoteDataSource.fetchPublisherById(
      publisher.id,
    );

    await remoteDataSource.editPublisher(
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
      batch: batch,
    );

    await relationshipSyncService.syncPublisherRelationships(
      publisherId: publisher.id,
      newBookIds: publisher.bookIds,
      oldBookIds: existingPublisher?.bookIds ?? <String>[],
      batch: batch,
    );
  }

  @override
  Future<void> removePublisher(String id, {WriteBatch? batch}) async {
    final PublisherModel? existingPublisher = await remoteDataSource.fetchPublisherById(id);

    if (existingPublisher != null) {
      await relationshipSyncService.removePublisherRelationships(
        publisherId: id,
        bookIds: existingPublisher.bookIds,
        batch: batch,
      );
    }

    await remoteDataSource.removePublisher(id, batch: batch);
  }
}

@riverpod
PublisherRepository publisherRepository(Ref ref) {
  final PublisherRemoteDataSource remoteDataSource = ref.watch(publisherRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return PublisherRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
