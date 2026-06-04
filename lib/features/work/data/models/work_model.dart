import '../../domain/entities/work_entity.dart';

class WorkModel extends WorkEntity {
  const WorkModel({
    required super.id,
    required super.title,
    required super.contentCategory,
    required super.isTranslation,
    required super.toBeTranslated,
    super.language,
    super.genre,
    super.originalTitle,
    super.originalLanguage,
    super.notes,
    required super.authorIds,
    required super.translatorIds,
    required super.sequenceVolumeIds,
    super.bookId,
    required super.createdDate,
    required super.lastUpdated,
  });
}
