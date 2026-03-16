import 'package:equatable/equatable.dart';

class PublisherEntity extends Equatable {
  const PublisherEntity({
    required this.id,

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

  PublisherEntity copyWith({
    String? id,
    String? name,
    String? logo,
    String? otherName,
    String? website,
    String? email,
    String? facebook,
    String? phoneNumber,
    List<String>? bookIds,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => PublisherEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    logo: logo ?? this.logo,
    otherName: otherName ?? this.otherName,
    website: website ?? this.website,
    email: email ?? this.email,
    facebook: facebook ?? this.facebook,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    bookIds: bookIds ?? this.bookIds,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
