import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../domain/entities/work_entity.dart';

class WorkModel extends WorkEntity {
  const WorkModel({
    required super.id,
    required super.title,
    required super.contentCategory,
    required super.isTranslation,
    super.language,
    super.genre,
    super.noOfPages,
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

  factory WorkModel.fromMap(Map<String, dynamic> map, String documentId) => WorkModel(
        id: documentId,
        title: (map['title'] as String?) ?? '',
        contentCategory:
            ContentCategory.values.asNameMap()[map['contentCategory'] as String?] ??
            ContentCategory.shortStory,
        isTranslation: (map['isTranslation'] as bool?) ?? false,
        language: Language.values.asNameMap()[map['language'] as String?],
        genre: Genre.values.asNameMap()[map['genre'] as String?],
        noOfPages: map['noOfPages'] as int?,
        originalTitle: map['originalTitle'] as String?,
        originalLanguage: OriginalLanguage.values.asNameMap()[map['originalLanguage'] as String?],
        notes: map['notes'] as String?,
        authorIds: List<String>.from(map['authorIds'] as Iterable<dynamic>? ?? <String>[]),
        translatorIds: List<String>.from(map['translatorIds'] as Iterable<dynamic>? ?? <String>[]),
        sequenceVolumeIds: List<String>.from(
          map['sequenceVolumeIds'] as Iterable<dynamic>? ?? <String>[],
        ),
        bookId: map['bookId'] as String?,
        createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'contentCategory': contentCategory.name,
        'isTranslation': isTranslation,
        'language': language?.name,
        'genre': genre?.name,
        'noOfPages': noOfPages,
        'originalTitle': originalTitle,
        'originalLanguage': originalLanguage?.name,
        'notes': notes,
        'authorIds': authorIds,
        'translatorIds': translatorIds,
        'sequenceVolumeIds': sequenceVolumeIds,
        'bookId': bookId,
        'createdDate': Timestamp.fromDate(createdDate),
        'lastUpdated': Timestamp.fromDate(lastUpdated),
      };
}
