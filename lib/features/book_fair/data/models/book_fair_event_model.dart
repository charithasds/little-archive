import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/entities/book_fair_hall_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';
import 'book_fair_hall_model.dart';
import 'book_fair_stall_model.dart';

class BookFairEventModel extends BookFairEventEntity {
  const BookFairEventModel({
    required super.id,
    required super.year,
    required super.title,
    required super.startDate,
    required super.endDate,
    required super.halls,
    required super.stalls,
  });

  factory BookFairEventModel.fromJson(Map<String, dynamic> json) => BookFairEventModel(
    id: json['id'] as String,
    year: json['year'] as int,
    title: json['title'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    halls: (json['halls'] as Iterable<dynamic>)
        .map<BookFairHallEntity>(
          (dynamic h) => BookFairHallModel.fromJson(h as Map<String, dynamic>),
        )
        .toList(),
    stalls: (json['stalls'] as Iterable<dynamic>)
        .map<BookFairStallEntity>(
          (dynamic s) => BookFairStallModel.fromJson(s as Map<String, dynamic>),
        )
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'year': year,
    'title': title,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'halls': halls.map((BookFairHallEntity h) => (h as BookFairHallModel).toJson()).toList(),
    'stalls': stalls.map((BookFairStallEntity s) => (s as BookFairStallModel).toJson()).toList(),
  };
}
