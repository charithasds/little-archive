import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../domain/entities/work_entity.dart';

class WorkModel extends WorkEntity {
  const WorkModel({
    required super.id,
    required super.title,
    required super.contentCategory,
    super.language,
    super.genre,
    super.noOfPages,
    required super.isTranslation,
    super.originalTitle,
    super.originalLanguage,
    required super.readingStatus,
    super.pausedPage,
    super.completedDate,
    super.notes,
    required super.createdDate,
    required super.lastUpdated,
    required super.authorIds,
    required super.translatorIds,
    required super.sequenceVolumeIds,
    super.bookId,
  });

  factory WorkModel.fromMap(Map<String, dynamic> map, String documentId) => WorkModel(
    id: documentId,
    title: (map['title'] as String?) ?? '',
    contentCategory: ContentCategory.values.byName(
      (map['contentCategory'] as String?) ?? 'shortStory',
    ),
    language: map['language'] != null ? Language.values.byName(map['language'] as String) : null,
    genre: map['genre'] != null ? Genre.values.byName(map['genre'] as String) : null,
    noOfPages: map['noOfPages'] as int?,
    isTranslation: (map['isTranslation'] as bool?) ?? false,
    originalTitle: map['originalTitle'] as String?,
    originalLanguage: map['originalLanguage'] != null
        ? OriginalLanguage.values.byName(map['originalLanguage'] as String)
        : null,
    readingStatus: ReadingStatus.values.byName((map['readingStatus'] as String?) ?? 'notStarted'),
    pausedPage: map['pausedPage'] as int?,
    completedDate: (map['completedDate'] as Timestamp?)?.toDate(),
    notes: map['notes'] as String?,
    createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    authorIds: List<String>.from(map['authorIds'] as Iterable<dynamic>? ?? <String>[]),
    translatorIds: List<String>.from(map['translatorIds'] as Iterable<dynamic>? ?? <String>[]),
    sequenceVolumeIds: List<String>.from(
      map['sequenceVolumeIds'] as Iterable<dynamic>? ?? <String>[],
    ),
    bookId: map['bookId'] as String?,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'contentCategory': contentCategory.name,
    'language': language?.name,
    'genre': genre?.name,
    'noOfPages': noOfPages,
    'isTranslation': isTranslation,
    'originalTitle': originalTitle,
    'originalLanguage': originalLanguage?.name,
    'readingStatus': readingStatus.name,
    'pausedPage': pausedPage,
    'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
    'notes': notes,
    'createdDate': Timestamp.fromDate(createdDate),
    'lastUpdated': Timestamp.fromDate(lastUpdated),
    'authorIds': authorIds,
    'translatorIds': translatorIds,
    'sequenceVolumeIds': sequenceVolumeIds,
    'bookId': bookId,
  };
}
