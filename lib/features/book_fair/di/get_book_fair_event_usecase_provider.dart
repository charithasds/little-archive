import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/book_fair_repository_impl.dart';
import '../domain/repositories/book_fair_repository.dart';
import '../domain/usecases/get_book_fair_event_usecase.dart';

export '../domain/usecases/get_book_fair_event_usecase.dart';

part 'get_book_fair_event_usecase_provider.g.dart';

@riverpod
GetBookFairEventUseCase getBookFairEventUseCase(Ref ref) {
  final BookFairRepository repository = ref.watch(bookFairRepositoryProvider);

  return GetBookFairEventUseCase(repository: repository);
}
