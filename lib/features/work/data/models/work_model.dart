import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/enums/work_type.dart';
import '../../domain/entities/work_entity.dart';

class WorkModel extends WorkEntity {
  const WorkModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.language,
    required super.genre,
    required super.workType,
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
    super.sequenceVolumeId,
    super.bookId,
  });

  factory WorkModel.fromMap(Map<String, dynamic> map, String documentId) => WorkModel(
    id: documentId,
    userId: (map['userId'] as String?) ?? '',
    title: (map['title'] as String?) ?? '',
    language: Language.values.byName((map['language'] as String?) ?? 'english'),
    genre: Genre.values.byName((map['genre'] as String?) ?? 'other'),
    workType: WorkType.values.byName((map['workType'] as String?) ?? 'shortStory'),
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
    sequenceVolumeId: map['sequenceVolumeId'] as String?,
    bookId: map['bookId'] as String?,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'title': title,
    'language': language.name,
    'genre': genre.name,
    'workType': workType.name,
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
    'sequenceVolumeId': sequenceVolumeId,
    'bookId': bookId,
  };
}
