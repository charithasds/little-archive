import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/publisher_remote_datasource.dart';
import '../../data/repositories/publisher_repository_impl.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../../domain/usecases/publisher_usecases.dart';

part 'publisher_provider.g.dart';

@riverpod
PublisherRemoteDataSource publisherRemoteDataSource(Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return PublisherRemoteDataSourceImpl(firestoreService: firestoreService);
    }

final Provider<PublisherRepository> publisherRepositoryProvider = Provider<PublisherRepository>((
  Ref ref,
) {
  final PublisherRemoteDataSource remoteDataSource = ref.watch(publisherRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );
  return PublisherRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
});

@riverpod
GetPublishersUseCase getPublishersUseCase(Ref ref) => GetPublishersUseCase(ref.watch(publisherRepositoryProvider));
@riverpod
WatchPublishersUseCase watchPublishersUseCase(Ref ref) => WatchPublishersUseCase(ref.watch(publisherRepositoryProvider));
@riverpod
GetPublisherByIdUseCase getPublisherByIdUseCase(Ref ref) => GetPublisherByIdUseCase(ref.watch(publisherRepositoryProvider));
@riverpod
AddPublisherUseCase addPublisherUseCase(Ref ref) => AddPublisherUseCase(ref.watch(publisherRepositoryProvider));
@riverpod
UpdatePublisherUseCase updatePublisherUseCase(Ref ref) => UpdatePublisherUseCase(ref.watch(publisherRepositoryProvider));
@riverpod
DeletePublisherUseCase deletePublisherUseCase(Ref ref) => DeletePublisherUseCase(ref.watch(publisherRepositoryProvider));

@riverpod
Stream<List<PublisherEntity>> publishersStream(Ref ref) {
      final WatchPublishersUseCase watchPublishers = ref.watch(watchPublishersUseCaseProvider);
      final UserEntity? user = ref.watch(authStateProvider).value;
      if (user == null) {
        return Stream<List<PublisherEntity>>.value(<PublisherEntity>[]);
      }
      return watchPublishers(user.uid);
    }
