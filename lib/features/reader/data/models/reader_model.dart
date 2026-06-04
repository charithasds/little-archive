import '../../domain/entities/reader_entity.dart';

class ReaderModel extends ReaderEntity {
  const ReaderModel({
    required super.id,
    required super.name,
    super.image,
    super.otherName,
    super.email,
    super.facebook,
    super.phoneNumber,
    required super.bookIds,
    required super.createdDate,
    required super.lastUpdated,
  });
}
