import 'package:equatable/equatable.dart';

class BookFairStallEntity extends Equatable {
  const BookFairStallEntity({
    required this.id,
    required this.name,
    required this.stallNo,
    required this.halls,
  });

  final String id;
  final String name;
  final String stallNo;
  final List<String> halls;

  @override
  List<Object?> get props => <Object?>[id];
}
