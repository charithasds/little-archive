import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/work_remote_datasource.dart';
import '../../data/repositories/work_repository_impl.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../../domain/usecases/work_usecases.dart';

part 'work_provider.g.dart';

@riverpod
WorkRemoteDataSource workRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);

  return WorkRemoteDataSourceImpl(firestoreService: firestoreService);
}

@riverpod
WorkRepository workRepository(Ref ref) {
  final WorkRemoteDataSource remoteDataSource = ref.watch(workRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return WorkRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GetWorksUseCase getWorksUseCase(Ref ref) => GetWorksUseCase(ref.watch(workRepositoryProvider));

@riverpod
WatchWorksUseCase watchWorksUseCase(Ref ref) =>
    WatchWorksUseCase(ref.watch(workRepositoryProvider));

@riverpod
GetWorkByIdUseCase getWorkByIdUseCase(Ref ref) =>
    GetWorkByIdUseCase(ref.watch(workRepositoryProvider));

@riverpod
AddWorkUseCase addWorkUseCase(Ref ref) => AddWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
UpdateWorkUseCase updateWorkUseCase(Ref ref) =>
    UpdateWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
DeleteWorkUseCase deleteWorkUseCase(Ref ref) =>
    DeleteWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
Stream<List<WorkEntity>> worksStream(Ref ref) {
  final WatchWorksUseCase watchWorks = ref.watch(watchWorksUseCaseProvider);
  final UserEntity? user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream<List<WorkEntity>>.value(<WorkEntity>[]);
  }

  return watchWorks(user.uid);
}
