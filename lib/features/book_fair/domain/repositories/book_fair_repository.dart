import '../entities/book_fair_event_entity.dart';

abstract class BookFairRepository {
  Future<BookFairEventEntity> getBookFairEvent();
}
