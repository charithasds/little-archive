import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/reader_remote_datasource.dart';
import '../../data/repositories/reader_repository_impl.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../../domain/usecases/reader_usecases.dart';

part 'reader_provider.g.dart';

@riverpod
ReaderRemoteDataSource readerRemoteDataSource(Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return ReaderRemoteDataSourceImpl(firestoreService: firestoreService);
    }

@riverpod
ReaderRepository readerRepository(Ref ref) {
  final ReaderRemoteDataSource remoteDataSource = ref.watch(readerRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );
  return ReaderRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GetReadersUseCase getReadersUseCase(Ref ref) => GetReadersUseCase(ref.watch(readerRepositoryProvider));
@riverpod
WatchReadersUseCase watchReadersUseCase(Ref ref) => WatchReadersUseCase(ref.watch(readerRepositoryProvider));
@riverpod
GetReaderByIdUseCase getReaderByIdUseCase(Ref ref) => GetReaderByIdUseCase(ref.watch(readerRepositoryProvider));
@riverpod
AddReaderUseCase addReaderUseCase(Ref ref) => AddReaderUseCase(ref.watch(readerRepositoryProvider));
@riverpod
UpdateReaderUseCase updateReaderUseCase(Ref ref) => UpdateReaderUseCase(ref.watch(readerRepositoryProvider));
@riverpod
DeleteReaderUseCase deleteReaderUseCase(Ref ref) => DeleteReaderUseCase(ref.watch(readerRepositoryProvider));

@riverpod
Stream<List<ReaderEntity>> readersStream(Ref ref) {
    final WatchReadersUseCase watchReaders = ref.watch(watchReadersUseCaseProvider);
    final UserEntity? user = ref.watch(authStateProvider).value;
    if (user == null) {
      return Stream<List<ReaderEntity>>.value(<ReaderEntity>[]);
    }
    return watchReaders(user.uid);
  }
