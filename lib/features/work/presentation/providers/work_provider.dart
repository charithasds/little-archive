import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/work_remote_datasource.dart';
import '../../data/repositories/work_repository_impl.dart';
import '../../domain/repositories/work_repository.dart';
import '../../domain/entities/work_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final workRemoteDataSourceProvider = Provider<WorkRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return WorkRemoteDataSourceImpl(firestore: firestore);
});

final workRepositoryProvider = Provider<WorkRepository>((ref) {
  final remoteDataSource = ref.watch(workRemoteDataSourceProvider);
  return WorkRepositoryImpl(remoteDataSource: remoteDataSource);
});

final worksStreamProvider = StreamProvider<List<WorkEntity>>((ref) {
  final repository = ref.watch(workRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return repository.watchWorks(user.uid);
});
