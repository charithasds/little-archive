import 'package:equatable/equatable.dart';

class ReaderEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? image;
  final String? otherName;
  final String? email;
  final String? facebook;
  final String? phoneNumber;
  final List<String> bookIds;
  final DateTime createdDate;
  final DateTime lastUpdated;

  const ReaderEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.image,
    this.otherName,
    this.email,
    this.facebook,
    this.phoneNumber,
    required this.bookIds,
    required this.createdDate,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [id];
}
