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
    required super.title,
    required super.compilationType,
    required super.isTranslation,
    super.cover,
    super.language,
    super.genre,
    super.isbn,
    super.publishedDate,
    super.noOfPages,
    super.originalTitle,
    super.originalLanguage,
    super.collectionStatus,
    super.collectedDate,
    super.lendedDate,
    super.dueDate,
    super.readingStatus,
    super.pausedPage,
    super.completedDate,
    super.notes,
    required super.authorIds,
    required super.translatorIds,
    required super.workIds,
    required super.sequenceVolumeIds,
    super.publisherId,
    super.readerId,
    required super.createdDate,
    required super.lastUpdated,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) => BookModel(
    id: documentId,
    title: (map['title'] as String?) ?? '',
    compilationType: CompilationType.values.byName(
      map['compilationType'] as String? ?? CompilationType.single.name,
    ),
    isTranslation: (map['isTranslation'] as bool?) ?? false,
    cover: map['cover'] as String?,
    language: Language.values.asNameMap()[map['language'] as String?],
    genre: Genre.values.asNameMap()[map['genre'] as String?],
    isbn: map['isbn'] as String?,
    publishedDate: (map['publishedDate'] as Timestamp?)?.toDate(),
    noOfPages: map['noOfPages'] as int?,
    originalTitle: map['originalTitle'] as String?,
    originalLanguage: OriginalLanguage.values.asNameMap()[map['originalLanguage'] as String?],
    collectionStatus:
        CollectionStatus.values.asNameMap()[map['collectionStatus'] as String?] ??
        CollectionStatus.collected,
    collectedDate: (map['collectedDate'] as Timestamp?)?.toDate(),
    lendedDate: (map['lendedDate'] as Timestamp?)?.toDate(),
    dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
    readingStatus:
        ReadingStatus.values.asNameMap()[map['readingStatus'] as String?] ??
        ReadingStatus.notStarted,
    pausedPage: map['pausedPage'] as int?,
    completedDate: (map['completedDate'] as Timestamp?)?.toDate(),
    notes: map['notes'] as String?,
    authorIds: List<String>.from(map['authorIds'] as Iterable<dynamic>? ?? <String>[]),
    translatorIds: List<String>.from(map['translatorIds'] as Iterable<dynamic>? ?? <String>[]),
    workIds: List<String>.from(map['workIds'] as Iterable<dynamic>? ?? <String>[]),
    sequenceVolumeIds: List<String>.from(
      map['sequenceVolumeIds'] as Iterable<dynamic>? ?? <String>[],
    ),
    publisherId: map['publisherId'] as String?,
    readerId: map['readerId'] as String?,
    createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'compilationType': compilationType.name,
    'isTranslation': isTranslation,
    'cover': cover,
    'language': language?.name,
    'genre': genre?.name,
    'isbn': isbn,
    'publishedDate': publishedDate != null ? Timestamp.fromDate(publishedDate!) : null,
    'noOfPages': noOfPages,
    'originalTitle': originalTitle,
    'originalLanguage': originalLanguage?.name,
    'collectionStatus': collectionStatus?.name,
    'collectedDate': collectedDate != null ? Timestamp.fromDate(collectedDate!) : null,
    'lendedDate': lendedDate != null ? Timestamp.fromDate(lendedDate!) : null,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    'readingStatus': readingStatus?.name,
    'pausedPage': pausedPage,
    'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
    'notes': notes,
    'authorIds': authorIds,
    'translatorIds': translatorIds,
    'workIds': workIds,
    'sequenceVolumeIds': sequenceVolumeIds,
    'publisherId': publisherId,
    'readerId': readerId,
    'createdDate': Timestamp.fromDate(createdDate),
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };
}
