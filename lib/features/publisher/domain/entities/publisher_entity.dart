import 'package:equatable/equatable.dart';

import '../../../../core/shared/domain/utils/nullable.dart';

class PublisherEntity extends Equatable {
  const PublisherEntity({
    required this.id,
    required this.name,
    required this.isSelfPublisher,
    this.logo,
    this.otherName,
    this.website,
    this.email,
    this.facebook,
    this.phoneNumber,
    required this.bookIds,
    this.bookFairPublisherId,
    required this.createdDate,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final bool isSelfPublisher;
  final String? logo;
  final String? otherName;
  final String? website;
  final String? email;
  final String? facebook;
  final String? phoneNumber;
  final List<String> bookIds;
  final String? bookFairPublisherId;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];

  PublisherEntity copyWith({
    String? id,
    String? name,
    bool? isSelfPublisher,
    Nullable<String?>? logo,
    Nullable<String?>? otherName,
    Nullable<String?>? website,
    Nullable<String?>? email,
    Nullable<String?>? facebook,
    Nullable<String?>? phoneNumber,
    List<String>? bookIds,
    Nullable<String?>? bookFairPublisherId,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => PublisherEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    isSelfPublisher: isSelfPublisher ?? this.isSelfPublisher,
    logo: logo != null ? logo.value : this.logo,
    otherName: otherName != null ? otherName.value : this.otherName,
    website: website != null ? website.value : this.website,
    email: email != null ? email.value : this.email,
    facebook: facebook != null ? facebook.value : this.facebook,
    phoneNumber: phoneNumber != null ? phoneNumber.value : this.phoneNumber,
    bookIds: bookIds ?? this.bookIds,
    bookFairPublisherId: bookFairPublisherId != null
        ? bookFairPublisherId.value
        : this.bookFairPublisherId,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
