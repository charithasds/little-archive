import 'package:equatable/equatable.dart';

import 'book_fair_hall_entity.dart';
import 'book_fair_stall_entity.dart';

class BookFairEventEntity extends Equatable {
  const BookFairEventEntity({
    required this.id,
    required this.year,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.halls,
    required this.stalls,
  });

  final String id;
  final int year;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<BookFairHallEntity> halls;
  final List<BookFairStallEntity> stalls;

  @override
  List<Object?> get props => <Object?>[id];
}
