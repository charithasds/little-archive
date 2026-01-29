import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/publisher_remote_datasource.dart';
import '../../data/repositories/publisher_repository_impl.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final publisherRemoteDataSourceProvider = Provider<PublisherRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return PublisherRemoteDataSourceImpl(firestore: firestore);
});

final publisherRepositoryProvider = Provider<PublisherRepository>((ref) {
  final remoteDataSource = ref.watch(publisherRemoteDataSourceProvider);
  return PublisherRepositoryImpl(remoteDataSource: remoteDataSource);
});

final publishersStreamProvider = StreamProvider<List<PublisherEntity>>((ref) {
  final repository = ref.watch(publisherRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return repository.watchPublishers(user.uid);
});
