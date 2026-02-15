import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.userId,
    required super.title,
    super.cover,
    required super.compilationType,
    required super.language,
    required super.genre,
    super.isbn,
    super.publishedDate,
    super.noOfPages,
    required super.isTranslation,
    super.originalTitle,
    super.originalLanguage,
    required super.collectionStatus,
    super.collectedDate,
    super.lendedDate,
    super.dueDate,
    required super.readingStatus,
    super.pausedPage,
    super.completedDate,
    super.notes,
    required super.createdDate,
    required super.lastUpdated,
    required super.authorIds,
    required super.translatorIds,
    required super.workIds,
    super.sequenceVolumeId,
    super.publisherId,
    super.readerId,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) => BookModel(
    id: documentId,
    userId: (map['userId'] as String?) ?? '',
    title: (map['title'] as String?) ?? '',
    cover: map['cover'] as String?,
    compilationType: CompilationType.values.byName((map['compilationType'] as String?) ?? 'single'),
    language: Language.values.byName((map['language'] as String?) ?? 'english'),
    genre: Genre.values.byName((map['genre'] as String?) ?? 'other'),
    isbn: map['isbn'] as String?,
    publishedDate: (map['publishedDate'] as Timestamp?)?.toDate(),
    noOfPages: map['noOfPages'] as int?,
    isTranslation: (map['isTranslation'] as bool?) ?? false,
    originalTitle: map['originalTitle'] as String?,
    originalLanguage: map['originalLanguage'] != null
        ? OriginalLanguage.values.byName(map['originalLanguage'] as String)
        : null,
    collectionStatus: CollectionStatus.values.byName(
      (map['collectionStatus'] as String?) ?? 'owned',
    ),
    collectedDate: (map['collectedDate'] as Timestamp?)?.toDate(),
    lendedDate: (map['lendedDate'] as Timestamp?)?.toDate(),
    dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
    readingStatus: ReadingStatus.values.byName((map['readingStatus'] as String?) ?? 'notStarted'),
    pausedPage: map['pausedPage'] as int?,
    completedDate: (map['completedDate'] as Timestamp?)?.toDate(),
    notes: map['notes'] as String?,
    createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    authorIds: List<String>.from(map['authorIds'] as Iterable<dynamic>? ?? <String>[]),
    translatorIds: List<String>.from(map['translatorIds'] as Iterable<dynamic>? ?? <String>[]),
    workIds: List<String>.from(map['workIds'] as Iterable<dynamic>? ?? <String>[]),
    sequenceVolumeId: map['sequenceVolumeId'] as String?,
    publisherId: map['publisherId'] as String?,
    readerId: map['readerId'] as String?,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'title': title,
    'cover': cover,
    'compilationType': compilationType.name,
    'language': language.name,
    'genre': genre.name,
    'isbn': isbn,
    'publishedDate': publishedDate != null ? Timestamp.fromDate(publishedDate!) : null,
    'noOfPages': noOfPages,
    'isTranslation': isTranslation,
    'originalTitle': originalTitle,
    'originalLanguage': originalLanguage?.name,
    'collectionStatus': collectionStatus.name,
    'collectedDate': collectedDate != null ? Timestamp.fromDate(collectedDate!) : null,
    'lendedDate': lendedDate != null ? Timestamp.fromDate(lendedDate!) : null,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    'readingStatus': readingStatus.name,
    'pausedPage': pausedPage,
    'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
    'notes': notes,
    'createdDate': Timestamp.fromDate(createdDate),
    'lastUpdated': Timestamp.fromDate(lastUpdated),
    'authorIds': authorIds,
    'translatorIds': translatorIds,
    'workIds': workIds,
    'sequenceVolumeId': sequenceVolumeId,
    'publisherId': publisherId,
    'readerId': readerId,
  };
}
