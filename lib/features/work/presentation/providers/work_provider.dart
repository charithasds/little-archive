import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_provider.dart';
import '../../data/datasources/work_remote_datasource.dart';
import '../../data/repositories/work_repository_impl.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';

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

final StreamProvider<List<WorkEntity>> worksStreamProvider = StreamProvider<List<WorkEntity>>((
  Ref ref,
) {
  final WorkRepository repository = ref.watch(workRepositoryProvider);
  final UserEntity? user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream<List<WorkEntity>>.value(<WorkEntity>[]);
  }
  return repository.watchWorks(user.uid);
});
