import 'package:equatable/equatable.dart';

class ReaderEntity extends Equatable {
  final String id;
  final String name;
  final String? image;
  final List<String> bookIds;

  const ReaderEntity({
    required this.id,
    required this.name,
    this.image,
    required this.bookIds,
  });

  @override
  List<Object?> get props => [id, name, image, bookIds];
}
