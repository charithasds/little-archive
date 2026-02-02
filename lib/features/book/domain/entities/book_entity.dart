import 'package:equatable/equatable.dart';

import '../../../../core/enums/collection_status.dart';
import '../../../../core/enums/compilation_type.dart';
import '../../../../core/enums/genre.dart';
import '../../../../core/enums/language.dart';
import '../../../../core/enums/original_language.dart';
import '../../../../core/enums/reading_status.dart';

class BookEntity extends Equatable {

  const BookEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.cover,
    required this.compilationType,
    required this.language,
    required this.genre,
    this.isbn,
    this.publishedDate,
    this.noOfPages,
    required this.isTranslation,
    this.originalTitle,
    this.originalLanguage,
    required this.collectionStatus,
    this.collectedDate,
    this.lendedDate,
    this.dueDate,
    required this.readingStatus,
    this.pausedPage,
    this.completedDate,
    this.notes,
    required this.createdDate,
    required this.lastUpdated,
    required this.authorIds,
    required this.translatorIds,
    required this.workIds,
    this.sequenceVolumeId,
    this.publisherId,
    this.readerId,
  });
  final String id;
  final String userId;
  final String title;
  final String? cover;
  final CompilationType compilationType;
  final Language language;
  final Genre genre;
  final String? isbn;
  final DateTime? publishedDate;
  final int? noOfPages;
  final bool isTranslation;
  final String? originalTitle;
  final OriginalLanguage? originalLanguage;
  final CollectionStatus collectionStatus;
  final DateTime? collectedDate;
  final DateTime? lendedDate;
  final DateTime? dueDate;
  final ReadingStatus readingStatus;
  final int? pausedPage;
  final DateTime? completedDate;
  final String? notes;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final List<String> authorIds;
  final List<String> translatorIds;
  final List<String> workIds;
  final String? sequenceVolumeId;
  final String? publisherId;
  final String? readerId;

  @override
  List<Object?> get props => <Object?>[id];

  BookEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? cover,
    CompilationType? compilationType,
    Language? language,
    Genre? genre,
    String? isbn,
    DateTime? publishedDate,
    int? noOfPages,
    bool? isTranslation,
    String? originalTitle,
    OriginalLanguage? originalLanguage,
    CollectionStatus? collectionStatus,
    DateTime? collectedDate,
    DateTime? lendedDate,
    DateTime? dueDate,
    ReadingStatus? readingStatus,
    int? pausedPage,
    DateTime? completedDate,
    String? notes,
    DateTime? createdDate,
    DateTime? lastUpdated,
    List<String>? authorIds,
    List<String>? translatorIds,
    List<String>? workIds,
    String? sequenceVolumeId,
    String? publisherId,
    String? readerId,
  }) {
    return BookEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      compilationType: compilationType ?? this.compilationType,
      language: language ?? this.language,
      genre: genre ?? this.genre,
      isbn: isbn ?? this.isbn,
      publishedDate: publishedDate ?? this.publishedDate,
      noOfPages: noOfPages ?? this.noOfPages,
      isTranslation: isTranslation ?? this.isTranslation,
      originalTitle: originalTitle ?? this.originalTitle,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      collectedDate: collectedDate ?? this.collectedDate,
      lendedDate: lendedDate ?? this.lendedDate,
      dueDate: dueDate ?? this.dueDate,
      readingStatus: readingStatus ?? this.readingStatus,
      pausedPage: pausedPage ?? this.pausedPage,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      authorIds: authorIds ?? this.authorIds,
      translatorIds: translatorIds ?? this.translatorIds,
      workIds: workIds ?? this.workIds,
      sequenceVolumeId: sequenceVolumeId ?? this.sequenceVolumeId,
      publisherId: publisherId ?? this.publisherId,
      readerId: readerId ?? this.readerId,
    );
  }
}
