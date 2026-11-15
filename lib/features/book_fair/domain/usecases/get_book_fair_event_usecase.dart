import '../entities/book_fair_event_entity.dart';
import '../repositories/book_fair_repository.dart';

class GetBookFairEventUseCase {
  GetBookFairEventUseCase({required this.repository});

  final BookFairRepository repository;

  Future<BookFairEventEntity> call() => repository.getBookFairEvent();
}
