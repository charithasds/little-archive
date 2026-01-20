import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/short_remote_datasource.dart';
import '../../data/repositories/short_repository_impl.dart';
import '../../domain/repositories/short_repository.dart';
import '../../domain/entities/short_entity.dart';

final shortRemoteDataSourceProvider = Provider<ShortRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ShortRemoteDataSourceImpl(firestore: firestore);
});

final shortRepositoryProvider = Provider<ShortRepository>((ref) {
  final remoteDataSource = ref.watch(shortRemoteDataSourceProvider);
  return ShortRepositoryImpl(remoteDataSource: remoteDataSource);
});

final shortsStreamProvider = StreamProvider<List<ShortEntity>>((ref) {
  final repository = ref.watch(shortRepositoryProvider);
  return repository.watchShorts();
});
