import 'package:equatable/equatable.dart';

class PublisherEntity extends Equatable {
  const PublisherEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.logo,
    this.otherName,
    this.website,
    this.email,
    this.facebook,
    this.phoneNumber,
    required this.bookIds,
    required this.createdDate,
    required this.lastUpdated,
  });
  final String id;
  final String userId;
  final String name;
  final String? logo;
  final String? otherName;
  final String? website;
  final String? email;
  final String? facebook;
  final String? phoneNumber;
  final List<String> bookIds;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];
}
