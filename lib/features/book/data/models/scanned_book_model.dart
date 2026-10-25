import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/utils/string_extensions.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scan/scanned_book_entity.dart';
import '../../domain/entities/scan/scanned_name_entity.dart';
import 'scanned_name_model.dart';

class ScannedBookModel extends ScannedBookEntity {
  const ScannedBookModel({
    required super.book,
    super.authors,
    super.translators,
    super.publisher,
    super.analysisError,
  });

  factory ScannedBookModel.fromMap(Map<String, dynamic> map) {
    final Language? language = Language.values.asNameMap()[map['language'] as String?];
    final OriginalLanguage? originalLanguage = OriginalLanguage.values
        .asNameMap()[map['originalLanguage'] as String?];
    final List<ScannedNameEntity> authors = (map['authorNames'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map(ScannedNameModel.fromMap)
        .toList();
    final List<ScannedNameEntity> translators =
        (map['translatorNames'] as List<dynamic>? ?? <dynamic>[])
            .cast<Map<String, dynamic>>()
            .map(ScannedNameModel.fromMap)
            .toList();
    final dynamic publisherRaw = map['publisher'];
    ScannedNameEntity? publisher = publisherRaw is Map<String, dynamic>
        ? ScannedNameModel.fromMap(publisherRaw)
        : null;

    if (publisher != null && publisher.name.trim().isEmpty) {
      publisher = null;
    }

    String? rawIsbn = (map['isbn'] as String?).cleanDummyData;
    if (rawIsbn != null) {
      final String cleanIsbn = rawIsbn.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
      if (cleanIsbn.length == 10) {
        rawIsbn = Validators.convertIsbn10To13(cleanIsbn) ?? rawIsbn;
      }
    }

    final BookEntity book = BookEntity(
      id: '',
      title: map['title'] as String? ?? '',
      compilationType: CompilationType.single,
      isTranslation: map['isTranslation'] as bool? ?? false,
      toBeTranslated: false,
      language: language,
      originalTitle: map['originalTitle'] as String?,
      originalLanguage: originalLanguage,
      collectionStatus: CollectionStatus.collected,
      readingStatus: ReadingStatus.notStarted,
      isbn: rawIsbn,
      authorIds: const <String>[],
      translatorIds: const <String>[],
      workIds: const <String>[],
      sequenceVolumeIds: const <String>[],
      notForSale: false,
      isSigned: false,
      hasBookmark: false,
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    return ScannedBookModel(
      book: book,
      authors: authors,
      translators: translators,
      publisher: publisher,
      analysisError: map['analysisError'] as String?,
    );
  }
}
