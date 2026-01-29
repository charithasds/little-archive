import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/reader_remote_datasource.dart';
import '../../data/repositories/reader_repository_impl.dart';
import '../../domain/repositories/reader_repository.dart';
import '../../domain/entities/reader_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final readerRemoteDataSourceProvider = Provider<ReaderRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ReaderRemoteDataSourceImpl(firestore: firestore);
});

final readerRepositoryProvider = Provider<ReaderRepository>((ref) {
  final remoteDataSource = ref.watch(readerRemoteDataSourceProvider);
  return ReaderRepositoryImpl(remoteDataSource: remoteDataSource);
});

final readersStreamProvider = StreamProvider<List<ReaderEntity>>((ref) {
  final repository = ref.watch(readerRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return repository.watchReaders(user.uid);
});
