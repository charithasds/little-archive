import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/presentation/providers/firestore_provider.dart';
import '../../data/datasources/reader_remote_datasource.dart';
import '../../data/repositories/reader_repository_impl.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';

final Provider<ReaderRemoteDataSource> readerRemoteDataSourceProvider =
    Provider<ReaderRemoteDataSource>((Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return ReaderRemoteDataSourceImpl(firestoreService: firestoreService);
    });

final Provider<ReaderRepository> readerRepositoryProvider = Provider<ReaderRepository>((Ref ref) {
  final ReaderRemoteDataSource remoteDataSource = ref.watch(readerRemoteDataSourceProvider);
  return ReaderRepositoryImpl(remoteDataSource: remoteDataSource);
});

final StreamProvider<List<ReaderEntity>> readersStreamProvider = StreamProvider<List<ReaderEntity>>(
  (Ref ref) {
    final ReaderRepository repository = ref.watch(readerRepositoryProvider);
    final UserEntity? user = ref.watch(authStateProvider).value;
    if (user == null) {
      return Stream<List<ReaderEntity>>.value(<ReaderEntity>[]);
    }
    return repository.watchReaders(user.uid);
  },
);
