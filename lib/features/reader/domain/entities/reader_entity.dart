import 'package:equatable/equatable.dart';

class ReaderEntity extends Equatable {
  const ReaderEntity({
    required this.id,

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
  final String id;

  final String name;
  final String? image;
  final String? otherName;
  final String? email;
  final String? facebook;
  final String? phoneNumber;
  final List<String> bookIds;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];

  ReaderEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? otherName,
    String? email,
    String? facebook,
    String? phoneNumber,
    List<String>? bookIds,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => ReaderEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    image: image ?? this.image,
    otherName: otherName ?? this.otherName,
    email: email ?? this.email,
    facebook: facebook ?? this.facebook,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    bookIds: bookIds ?? this.bookIds,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
