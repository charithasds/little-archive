import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/author_remote_datasource.dart';
import '../../data/repositories/author_repository_impl.dart';
import '../../domain/repositories/author_repository.dart';
import '../../domain/entities/author_entity.dart';

final authorRemoteDataSourceProvider = Provider<AuthorRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AuthorRemoteDataSourceImpl(firestore: firestore);
});

final authorRepositoryProvider = Provider<AuthorRepository>((ref) {
  final remoteDataSource = ref.watch(authorRemoteDataSourceProvider);
  return AuthorRepositoryImpl(remoteDataSource: remoteDataSource);
});

final authorsStreamProvider = StreamProvider<List<AuthorEntity>>((ref) {
  final repository = ref.watch(authorRepositoryProvider);
  return repository.watchAuthors();
});
