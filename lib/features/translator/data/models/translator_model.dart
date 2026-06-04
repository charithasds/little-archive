import '../../domain/entities/translator_entity.dart';

class TranslatorModel extends TranslatorEntity {
  const TranslatorModel({
    required super.id,
    required super.name,
    super.image,
    super.otherName,
    super.website,
    super.facebook,
    required super.bookIds,
    required super.workIds,
    required super.createdDate,
    required super.lastUpdated,
  });
}
