import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/work_remote_datasource.dart';
import '../../data/repositories/work_repository_impl.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../../domain/usecases/work_usecases.dart';

part 'work_provider.g.dart';

@riverpod
WorkRemoteDataSource _workRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return WorkRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
WorkRepository _workRepository(Ref ref) {
  final WorkRemoteDataSource remoteDataSource = ref.watch(_workRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return WorkRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GenerateWorkIdUseCase generateWorkIdUseCase(Ref ref) =>
    GenerateWorkIdUseCase(ref.watch(_workRepositoryProvider));

@riverpod
FetchWorksUseCase fetchWorksUseCase(Ref ref) =>
    FetchWorksUseCase(ref.watch(_workRepositoryProvider));

@riverpod
FetchWorkByIdUseCase fetchWorkByIdUseCase(Ref ref) =>
    FetchWorkByIdUseCase(ref.watch(_workRepositoryProvider));

@riverpod
WatchWorksUseCase watchWorksUseCase(Ref ref) =>
    WatchWorksUseCase(ref.watch(_workRepositoryProvider));

@riverpod
AddWorkUseCase addWorkUseCase(Ref ref) => AddWorkUseCase(ref.watch(_workRepositoryProvider));

@riverpod
EditWorkUseCase editWorkUseCase(Ref ref) => EditWorkUseCase(ref.watch(_workRepositoryProvider));

@riverpod
RemoveWorkUseCase removeWorkUseCase(Ref ref) =>
    RemoveWorkUseCase(ref.watch(_workRepositoryProvider));

@riverpod
Stream<List<WorkEntity>> worksStream(Ref ref) {
  final WatchWorksUseCase watchWorks = ref.watch(watchWorksUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<WorkEntity>>.value(<WorkEntity>[]);
  }

  return watchWorks();
}
