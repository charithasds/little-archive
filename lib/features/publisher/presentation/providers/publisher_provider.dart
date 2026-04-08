import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final Provider<PublisherRemoteDataSource> publisherRemoteDataSourceProvider =
    Provider<PublisherRemoteDataSource>((Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return PublisherRemoteDataSourceImpl(firestoreService: firestoreService);
    });

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

final Provider<GetPublishersUseCase> getPublishersUseCaseProvider = Provider<GetPublishersUseCase>(
  (Ref ref) => GetPublishersUseCase(ref.watch(publisherRepositoryProvider)),
);
final Provider<WatchPublishersUseCase> watchPublishersUseCaseProvider =
    Provider<WatchPublishersUseCase>(
      (Ref ref) => WatchPublishersUseCase(ref.watch(publisherRepositoryProvider)),
    );
final Provider<GetPublisherByIdUseCase> getPublisherByIdUseCaseProvider =
    Provider<GetPublisherByIdUseCase>(
      (Ref ref) => GetPublisherByIdUseCase(ref.watch(publisherRepositoryProvider)),
    );
final Provider<AddPublisherUseCase> addPublisherUseCaseProvider = Provider<AddPublisherUseCase>(
  (Ref ref) => AddPublisherUseCase(ref.watch(publisherRepositoryProvider)),
);
final Provider<UpdatePublisherUseCase> updatePublisherUseCaseProvider =
    Provider<UpdatePublisherUseCase>(
      (Ref ref) => UpdatePublisherUseCase(ref.watch(publisherRepositoryProvider)),
    );
final Provider<DeletePublisherUseCase> deletePublisherUseCaseProvider =
    Provider<DeletePublisherUseCase>(
      (Ref ref) => DeletePublisherUseCase(ref.watch(publisherRepositoryProvider)),
    );

final StreamProvider<List<PublisherEntity>> publishersStreamProvider =
    StreamProvider<List<PublisherEntity>>((Ref ref) {
      final WatchPublishersUseCase watchPublishers = ref.watch(watchPublishersUseCaseProvider);
      final UserEntity? user = ref.watch(authStateProvider).value;
      if (user == null) {
        return Stream<List<PublisherEntity>>.value(<PublisherEntity>[]);
      }
      return watchPublishers(user.uid);
    });
