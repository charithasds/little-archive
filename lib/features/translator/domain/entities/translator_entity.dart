import 'package:equatable/equatable.dart';

class TranslatorEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? image;
  final String? otherName;
  final String? website;
  final String? facebook;
  final List<String> bookIds;
  final List<String> workIds;
  final DateTime createdDate;
  final DateTime lastUpdated;

  const TranslatorEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.image,
    this.otherName,
    this.website,
    this.facebook,
    required this.bookIds,
    required this.workIds,
    required this.createdDate,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [id];
}
