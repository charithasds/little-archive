import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/publisher_remote_datasource.dart';
import '../../data/repositories/publisher_repository_impl.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../../domain/usecases/publisher_usecases.dart';

part 'publisher_provider.g.dart';

@riverpod
PublisherRemoteDataSource _publisherRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return PublisherRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
PublisherRepository _publisherRepository(Ref ref) {
  final PublisherRemoteDataSource remoteDataSource = ref.watch(_publisherRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return PublisherRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GeneratePublisherIdUseCase generatePublisherIdUseCase(Ref ref) =>
    GeneratePublisherIdUseCase(ref.watch(_publisherRepositoryProvider));

@riverpod
FetchPublishersUseCase fetchPublishersUseCase(Ref ref) =>
    FetchPublishersUseCase(ref.watch(_publisherRepositoryProvider));

@riverpod
FetchPublisherByIdUseCase fetchPublisherByIdUseCase(Ref ref) =>
    FetchPublisherByIdUseCase(ref.watch(_publisherRepositoryProvider));

@riverpod
WatchPublishersUseCase watchPublishersUseCase(Ref ref) =>
    WatchPublishersUseCase(ref.watch(_publisherRepositoryProvider));

@riverpod
AddPublisherUseCase addPublisherUseCase(Ref ref) =>
    AddPublisherUseCase(ref.watch(_publisherRepositoryProvider));

@riverpod
EditPublisherUseCase editPublisherUseCase(Ref ref) =>
    EditPublisherUseCase(ref.watch(_publisherRepositoryProvider));

@riverpod
RemovePublisherUseCase removePublisherUseCase(Ref ref) =>
    RemovePublisherUseCase(ref.watch(_publisherRepositoryProvider));

@riverpod
Stream<List<PublisherEntity>> publishersStream(Ref ref) {
  final WatchPublishersUseCase watchPublishers = ref.watch(watchPublishersUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<PublisherEntity>>.value(<PublisherEntity>[]);
  }

  return watchPublishers();
}
