import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final Provider<WorkRemoteDataSource> workRemoteDataSourceProvider = Provider<WorkRemoteDataSource>((
  Ref ref,
) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  return WorkRemoteDataSourceImpl(firestoreService: firestoreService);
});

final Provider<WorkRepository> workRepositoryProvider = Provider<WorkRepository>((Ref ref) {
  final WorkRemoteDataSource remoteDataSource = ref.watch(workRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );
  return WorkRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
});

final Provider<GetWorksUseCase> getWorksUseCaseProvider = Provider<GetWorksUseCase>(
  (Ref ref) => GetWorksUseCase(ref.watch(workRepositoryProvider)),
);

final Provider<WatchWorksUseCase> watchWorksUseCaseProvider = Provider<WatchWorksUseCase>(
  (Ref ref) => WatchWorksUseCase(ref.watch(workRepositoryProvider)),
);

final Provider<GetWorkByIdUseCase> getWorkByIdUseCaseProvider = Provider<GetWorkByIdUseCase>(
  (Ref ref) => GetWorkByIdUseCase(ref.watch(workRepositoryProvider)),
);

final Provider<AddWorkUseCase> addWorkUseCaseProvider = Provider<AddWorkUseCase>(
  (Ref ref) => AddWorkUseCase(ref.watch(workRepositoryProvider)),
);

final Provider<UpdateWorkUseCase> updateWorkUseCaseProvider = Provider<UpdateWorkUseCase>(
  (Ref ref) => UpdateWorkUseCase(ref.watch(workRepositoryProvider)),
);

final Provider<DeleteWorkUseCase> deleteWorkUseCaseProvider = Provider<DeleteWorkUseCase>(
  (Ref ref) => DeleteWorkUseCase(ref.watch(workRepositoryProvider)),
);

final StreamProvider<List<WorkEntity>> worksStreamProvider = StreamProvider<List<WorkEntity>>((
  Ref ref,
) async* {
  final UserEntity? user = ref.watch(authStateProvider).value;
  if (user == null) {
    yield <WorkEntity>[];
  } else {
    final WatchWorksUseCase watchWorks = ref.watch(watchWorksUseCaseProvider);
    yield* await watchWorks(user.uid);
  }
});
