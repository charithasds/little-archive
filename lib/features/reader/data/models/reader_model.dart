import '../../domain/entities/reader_entity.dart';

class ReaderModel extends ReaderEntity {
  const ReaderModel({
    required super.id,
    required super.name,
    super.image,
    required super.bookIds,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'image': image, 'bookIds': bookIds};
  }

  factory ReaderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReaderModel(
      id: documentId,
      name: map['name'] ?? '',
      image: map['image'],
      bookIds: List<String>.from(map['bookIds'] ?? []),
    );
  }
}
