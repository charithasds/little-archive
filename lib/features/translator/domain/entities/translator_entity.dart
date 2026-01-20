import 'package:equatable/equatable.dart';

class TranslatorEntity extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String? otherName;
  final String? website;
  final String? facebook;
  final List<String> bookIds;
  final List<String> shortIds;

  const TranslatorEntity({
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
