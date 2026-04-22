import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/reader_remote_datasource.dart';
import '../../data/repositories/reader_repository_impl.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../../domain/usecases/reader_usecases.dart';

part 'reader_provider.g.dart';

@riverpod
ReaderRemoteDataSource _readerRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return ReaderRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
ReaderRepository _readerRepository(Ref ref) {
  final ReaderRemoteDataSource remoteDataSource = ref.watch(_readerRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return ReaderRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GenerateReaderIdUseCase generateReaderIdUseCase(Ref ref) =>
    GenerateReaderIdUseCase(ref.watch(_readerRepositoryProvider));

@riverpod
FetchReadersUseCase fetchReadersUseCase(Ref ref) =>
    FetchReadersUseCase(ref.watch(_readerRepositoryProvider));

@riverpod
FetchReaderByIdUseCase fetchReaderByIdUseCase(Ref ref) =>
    FetchReaderByIdUseCase(ref.watch(_readerRepositoryProvider));

@riverpod
WatchReadersUseCase watchReadersUseCase(Ref ref) =>
    WatchReadersUseCase(ref.watch(_readerRepositoryProvider));

@riverpod
AddReaderUseCase addReaderUseCase(Ref ref) => AddReaderUseCase(ref.watch(_readerRepositoryProvider));

@riverpod
EditReaderUseCase editReaderUseCase(Ref ref) =>
    EditReaderUseCase(ref.watch(_readerRepositoryProvider));

@riverpod
RemoveReaderUseCase removeReaderUseCase(Ref ref) =>
    RemoveReaderUseCase(ref.watch(_readerRepositoryProvider));

@riverpod
Stream<List<ReaderEntity>> readersStream(Ref ref) {
  final WatchReadersUseCase watchReaders = ref.watch(watchReadersUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<ReaderEntity>>.value(<ReaderEntity>[]);
  }

  return watchReaders();
}
