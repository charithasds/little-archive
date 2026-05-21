import '../../domain/entities/book_fair_stall_entity.dart';

class BookFairStallModel extends BookFairStallEntity {
  const BookFairStallModel({
    required super.id,
    required super.name,
    required super.stallNo,
    required super.halls,
  });

  factory BookFairStallModel.fromJson(Map<String, dynamic> json) => BookFairStallModel(
    id: json['id'] as String,
    name: json['name'] as String,
    stallNo: json['stallNo'] as String,
    halls: List<String>.from(json['halls'] as Iterable<dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'stallNo': stallNo,
    'halls': halls,
  };
}
