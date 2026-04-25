import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/book_usecases.dart';

part 'book_provider.g.dart';

@riverpod
Stream<List<BookEntity>> booksStream(Ref ref) {
  final WatchBooksUseCase watchBooks = ref.watch(watchBooksUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<BookEntity>>.value(<BookEntity>[]);
  }

  return watchBooks();
}
