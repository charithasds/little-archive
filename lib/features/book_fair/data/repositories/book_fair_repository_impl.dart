import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/repositories/book_fair_repository.dart';
import '../datasources/book_fair_local_datasource.dart';

part 'book_fair_repository_impl.g.dart';

class BookFairRepositoryImpl implements BookFairRepository {
  BookFairRepositoryImpl({required this.localDataSource});

  final BookFairLocalDataSource localDataSource;

  @override
  Future<BookFairEventEntity> getBookFairEvent() => localDataSource.getBookFairEvent();
}

@riverpod
BookFairRepository bookFairRepository(Ref ref) {
  final BookFairLocalDataSource localDataSource = ref.watch(bookFairLocalDataSourceProvider);

  return BookFairRepositoryImpl(localDataSource: localDataSource);
}
