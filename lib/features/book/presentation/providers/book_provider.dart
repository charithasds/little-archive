import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firestore_provider.dart';
import '../../data/datasources/book_remote_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/entities/book_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final bookRemoteDataSourceProvider = Provider<BookRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return BookRemoteDataSourceImpl(firestore: firestore);
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final remoteDataSource = ref.watch(bookRemoteDataSourceProvider);
  return BookRepositoryImpl(remoteDataSource: remoteDataSource);
});

final booksStreamProvider = StreamProvider<List<BookEntity>>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return repository.watchBooks(user.uid);
});
