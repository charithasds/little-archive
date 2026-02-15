import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/presentation/providers/firestore_provider.dart';
import '../../data/datasources/publisher_remote_datasource.dart';
import '../../data/repositories/publisher_repository_impl.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';

final Provider<PublisherRemoteDataSource> publisherRemoteDataSourceProvider =
    Provider<PublisherRemoteDataSource>((Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return PublisherRemoteDataSourceImpl(firestoreService: firestoreService);
    });

final Provider<PublisherRepository> publisherRepositoryProvider = Provider<PublisherRepository>((
  Ref ref,
) {
  final PublisherRemoteDataSource remoteDataSource = ref.watch(publisherRemoteDataSourceProvider);
  return PublisherRepositoryImpl(remoteDataSource: remoteDataSource);
});

final StreamProvider<List<PublisherEntity>> publishersStreamProvider =
    StreamProvider<List<PublisherEntity>>((Ref ref) {
      final PublisherRepository repository = ref.watch(publisherRepositoryProvider);
      final UserEntity? user = ref.watch(authStateProvider).value;
      if (user == null) {
        return Stream<List<PublisherEntity>>.value(<PublisherEntity>[]);
      }
      return repository.watchPublishers(user.uid);
    });
