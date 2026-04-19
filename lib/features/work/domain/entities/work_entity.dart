import 'package:equatable/equatable.dart';

import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';

class WorkEntity extends Equatable {
  const WorkEntity({
    required this.id,
    required this.title,
    required this.contentCategory,
    this.language,
    this.genre,
    this.noOfPages,
    required this.isTranslation,
    this.originalTitle,
    this.originalLanguage,
    required this.readingStatus,
    this.pausedPage,
    this.completedDate,
    this.notes,
    required this.createdDate,
    required this.lastUpdated,
    required this.authorIds,
    required this.translatorIds,
    required this.sequenceVolumeIds,
    this.bookId,
  });

  final String id;
  final String title;
  final ContentCategory contentCategory;
  final Language? language;
  final Genre? genre;
  final int? noOfPages;
  final bool isTranslation;
  final String? originalTitle;
  final OriginalLanguage? originalLanguage;
  final ReadingStatus readingStatus;
  final int? pausedPage;
  final DateTime? completedDate;
  final String? notes;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final List<String> authorIds;
  final List<String> translatorIds;
  final List<String> sequenceVolumeIds;
  final String? bookId;

  @override
  List<Object?> get props => <Object?>[id];

  WorkEntity copyWith({
    String? id,
    String? title,
    ContentCategory? contentCategory,
    Nullable<Language?>? language,
    Nullable<Genre?>? genre,
    Nullable<int?>? noOfPages,
    bool? isTranslation,
    Nullable<String?>? originalTitle,
    Nullable<OriginalLanguage?>? originalLanguage,
    ReadingStatus? readingStatus,
    Nullable<int?>? pausedPage,
    Nullable<DateTime?>? completedDate,
    Nullable<String?>? notes,
    DateTime? createdDate,
    DateTime? lastUpdated,
    List<String>? authorIds,
    List<String>? translatorIds,
    List<String>? sequenceVolumeIds,
    Nullable<String?>? bookId,
  }) => WorkEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    contentCategory: contentCategory ?? this.contentCategory,
    language: language != null ? language.value : this.language,
    genre: genre != null ? genre.value : this.genre,
    noOfPages: noOfPages != null ? noOfPages.value : this.noOfPages,
    isTranslation: isTranslation ?? this.isTranslation,
    originalTitle: originalTitle != null ? originalTitle.value : this.originalTitle,
    originalLanguage: originalLanguage != null ? originalLanguage.value : this.originalLanguage,
    readingStatus: readingStatus ?? this.readingStatus,
    pausedPage: pausedPage != null ? pausedPage.value : this.pausedPage,
    completedDate: completedDate != null ? completedDate.value : this.completedDate,
    notes: notes != null ? notes.value : this.notes,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    authorIds: authorIds ?? this.authorIds,
    translatorIds: translatorIds ?? this.translatorIds,
    sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
    bookId: bookId != null ? bookId.value : this.bookId,
  );
}
