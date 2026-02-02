import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/publisher_remote_datasource.dart';
import '../../data/repositories/publisher_repository_impl.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';

final Provider<PublisherRemoteDataSource> publisherRemoteDataSourceProvider =
    Provider<PublisherRemoteDataSource>((Ref ref) {
      final FirebaseFirestore firestore = ref.watch(firestoreProvider);
      return PublisherRemoteDataSourceImpl(firestore: firestore);
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
