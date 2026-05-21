import '../../domain/entities/book_fair_hall_entity.dart';

class BookFairHallModel extends BookFairHallEntity {
  const BookFairHallModel({required super.id, required super.name});

  factory BookFairHallModel.fromJson(Map<String, dynamic> json) =>
      BookFairHallModel(id: json['id'] as String, name: json['name'] as String);

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};
}
