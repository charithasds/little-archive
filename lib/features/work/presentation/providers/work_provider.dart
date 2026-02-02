import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_provider.dart';
import '../../../../core/services/relationship_sync_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/work_remote_datasource.dart';
import '../../data/repositories/work_repository_impl.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';

final Provider<WorkRemoteDataSource> workRemoteDataSourceProvider = Provider<WorkRemoteDataSource>((
  Ref ref,
) {
  final FirebaseFirestore firestore = ref.watch(firestoreProvider);
  return WorkRemoteDataSourceImpl(firestore: firestore);
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
