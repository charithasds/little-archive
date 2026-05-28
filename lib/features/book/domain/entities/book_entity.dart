import 'package:equatable/equatable.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';

class BookEntity extends Equatable {
  const BookEntity({
    required this.id,
    required this.title,
    required this.compilationType,
    required this.isTranslation,
    required this.toBeTranslated,
    this.cover,
    this.language,
    this.genre,
    this.isbn,
    this.publishedDate,
    this.noOfPages,
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
    required this.authorIds,
    required this.translatorIds,
    required this.workIds,
    required this.sequenceVolumeIds,
    this.publisherId,
    this.readerId,
    required this.createdDate,
    required this.lastUpdated,
  });

  final String id;
  final String title;
  final CompilationType compilationType;
  final bool isTranslation;
  final bool toBeTranslated;
  final String? cover;
  final Language? language;
  final Genre? genre;
  final String? isbn;
  final DateTime? publishedDate;
  final int? noOfPages;
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
  final List<String> authorIds;
  final List<String> translatorIds;
  final List<String> workIds;
  final List<String> sequenceVolumeIds;
  final String? publisherId;
  final String? readerId;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];

  BookEntity copyWith({
    String? id,
    String? title,
    CompilationType? compilationType,
    bool? isTranslation,
    bool? toBeTranslated,
    Nullable<String?>? cover,
    Nullable<Language?>? language,
    Nullable<Genre?>? genre,
    Nullable<String?>? isbn,
    Nullable<DateTime?>? publishedDate,
    Nullable<int?>? noOfPages,
    Nullable<String?>? originalTitle,
    Nullable<OriginalLanguage?>? originalLanguage,
    CollectionStatus? collectionStatus,
    Nullable<DateTime?>? collectedDate,
    Nullable<DateTime?>? lendedDate,
    Nullable<DateTime?>? dueDate,
    ReadingStatus? readingStatus,
    Nullable<int?>? pausedPage,
    Nullable<DateTime?>? completedDate,
    Nullable<String?>? notes,
    List<String>? authorIds,
    List<String>? translatorIds,
    List<String>? workIds,
    List<String>? sequenceVolumeIds,
    Nullable<String?>? publisherId,
    Nullable<String?>? readerId,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => BookEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    compilationType: compilationType ?? this.compilationType,
    isTranslation: isTranslation ?? this.isTranslation,
    toBeTranslated: toBeTranslated ?? this.toBeTranslated,
    cover: cover != null ? cover.value : this.cover,
    language: language != null ? language.value : this.language,
    genre: genre != null ? genre.value : this.genre,
    isbn: isbn != null ? isbn.value : this.isbn,
    publishedDate: publishedDate != null ? publishedDate.value : this.publishedDate,
    noOfPages: noOfPages != null ? noOfPages.value : this.noOfPages,
    originalTitle: originalTitle != null ? originalTitle.value : this.originalTitle,
    originalLanguage: originalLanguage != null ? originalLanguage.value : this.originalLanguage,
    collectionStatus: collectionStatus ?? this.collectionStatus,
    collectedDate: collectedDate != null ? collectedDate.value : this.collectedDate,
    lendedDate: lendedDate != null ? lendedDate.value : this.lendedDate,
    dueDate: dueDate != null ? dueDate.value : this.dueDate,
    readingStatus: readingStatus ?? this.readingStatus,
    pausedPage: pausedPage != null ? pausedPage.value : this.pausedPage,
    completedDate: completedDate != null ? completedDate.value : this.completedDate,
    notes: notes != null ? notes.value : this.notes,
    authorIds: authorIds ?? this.authorIds,
    translatorIds: translatorIds ?? this.translatorIds,
    workIds: workIds ?? this.workIds,
    sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
    publisherId: publisherId != null ? publisherId.value : this.publisherId,
    readerId: readerId != null ? readerId.value : this.readerId,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
