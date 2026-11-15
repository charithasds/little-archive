import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../book/data/repositories/book_repository_impl.dart';
import '../../book/domain/repositories/book_repository.dart';
import '../data/services/book_fair_sheets_service.dart';

export '../data/services/book_fair_sheets_service.dart';

part 'book_fair_sheets_service_provider.g.dart';

@riverpod
BookFairSheetsService bookFairSheetsService(Ref ref) {
  final BookRepository bookRepository = ref.watch(bookRepositoryProvider);
  return BookFairSheetsService(bookRepository: bookRepository);
}
