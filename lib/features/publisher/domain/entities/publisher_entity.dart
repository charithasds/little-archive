import 'package:equatable/equatable.dart';

class PublisherEntity extends Equatable {
  final String id;
  final String name;
  final String? logo;
  final String? website;
  final String? email;
  final List<String> bookIds;

  const PublisherEntity({
    required this.id,
    required this.name,
    this.logo,
    this.website,
    this.email,
    required this.bookIds,
  });

  @override
  List<Object?> get props => [id, name, logo, website, email, bookIds];
}
