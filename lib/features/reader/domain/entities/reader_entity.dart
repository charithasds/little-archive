import 'package:equatable/equatable.dart';
import '../../../../core/shared/domain/utils/nullable.dart';

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
    Nullable<String?>? image,
    Nullable<String?>? otherName,
    Nullable<String?>? email,
    Nullable<String?>? facebook,
    Nullable<String?>? phoneNumber,
    List<String>? bookIds,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => ReaderEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    image: image != null ? image.value : this.image,
    otherName: otherName != null ? otherName.value : this.otherName,
    email: email != null ? email.value : this.email,
    facebook: facebook != null ? facebook.value : this.facebook,
    phoneNumber: phoneNumber != null ? phoneNumber.value : this.phoneNumber,
    bookIds: bookIds ?? this.bookIds,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
