import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/book_fair_repository_impl.dart';
import '../entities/book_fair_event_entity.dart';
import '../repositories/book_fair_repository.dart';

part 'get_book_fair_event_usecase.g.dart';

class GetBookFairEventUseCase {
  GetBookFairEventUseCase({required this.repository});

  final BookFairRepository repository;

  Future<BookFairEventEntity> call() => repository.getBookFairEvent();
}

@riverpod
GetBookFairEventUseCase getBookFairEventUseCase(Ref ref) {
  final BookFairRepository repository = ref.watch(bookFairRepositoryProvider);

  return GetBookFairEventUseCase(repository: repository);
}
