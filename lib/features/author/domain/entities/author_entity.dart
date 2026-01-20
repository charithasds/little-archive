import 'package:equatable/equatable.dart';

class AuthorEntity extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String? otherName;
  final String? website;
  final String? facebook;
  final List<String> bookIds;
  final List<String> shortIds;

  const AuthorEntity({
    required this.id,
    required this.name,
    this.image,
    this.otherName,
    this.website,
    this.facebook,
    required this.bookIds,
    required this.shortIds,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    otherName,
    website,
    facebook,
    bookIds,
    shortIds,
  ];
}
