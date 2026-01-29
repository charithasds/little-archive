import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/language.dart';
import '../../../../core/enums/genre.dart';
import '../../../../core/enums/original_language.dart';
import '../../../../core/enums/reading_status.dart';
import '../../../../core/enums/work_type.dart';
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

  Map<String, dynamic> toMap() {
    return {
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
      'completedDate': completedDate != null
          ? Timestamp.fromDate(completedDate!)
          : null,
      'notes': notes,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'authorIds': authorIds,
      'translatorIds': translatorIds,
      'sequenceVolumeId': sequenceVolumeId,
      'bookId': bookId,
    };
  }

  factory WorkModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WorkModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      language: Language.values.byName(map['language'] ?? 'english'),
      genre: Genre.values.byName(map['genre'] ?? 'other'),
      workType: WorkType.values.byName(map['workType'] ?? 'shortStory'),
      noOfPages: map['noOfPages'],
      isTranslation: map['isTranslation'] ?? false,
      originalTitle: map['originalTitle'],
      originalLanguage: map['originalLanguage'] != null
          ? OriginalLanguage.values.byName(map['originalLanguage'])
          : null,
      readingStatus: ReadingStatus.values.byName(
        map['readingStatus'] ?? 'notStarted',
      ),
      pausedPage: map['pausedPage'],
      completedDate: (map['completedDate'] as Timestamp?)?.toDate(),
      notes: map['notes'],
      createdDate:
          (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorIds: List<String>.from(map['authorIds'] ?? []),
      translatorIds: List<String>.from(map['translatorIds'] ?? []),
      sequenceVolumeId: map['sequenceVolumeId'],
      bookId: map['bookId'],
    );
  }
}
