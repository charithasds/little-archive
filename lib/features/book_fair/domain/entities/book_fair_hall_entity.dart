import 'package:equatable/equatable.dart';

class BookFairHallEntity extends Equatable {
  const BookFairHallEntity({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => <Object?>[id];
}
