import 'package:equatable/equatable.dart';

import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/utils/nullable.dart';

class WorkEntity extends Equatable {
  const WorkEntity({
    required this.id,
    required this.title,
    required this.contentCategory,
    required this.isTranslation,
    this.language,
    this.genre,
    this.originalTitle,
    this.originalLanguage,
    this.notes,
    required this.authorIds,
    required this.translatorIds,
    required this.sequenceVolumeIds,
    this.bookId,
    required this.createdDate,
    required this.lastUpdated,
  });

  final String id;
  final String title;
  final ContentCategory contentCategory;
  final bool isTranslation;
  final Language? language;
  final Genre? genre;
  final String? originalTitle;
  final OriginalLanguage? originalLanguage;
  final String? notes;
  final List<String> authorIds;
  final List<String> translatorIds;
  final List<String> sequenceVolumeIds;
  final String? bookId;
  final DateTime createdDate;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => <Object?>[id];

  WorkEntity copyWith({
    String? id,
    String? title,
    ContentCategory? contentCategory,
    bool? isTranslation,
    Nullable<Language?>? language,
    Nullable<Genre?>? genre,
    Nullable<String?>? originalTitle,
    Nullable<OriginalLanguage?>? originalLanguage,
    Nullable<String?>? notes,
    List<String>? authorIds,
    List<String>? translatorIds,
    List<String>? sequenceVolumeIds,
    Nullable<String?>? bookId,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) => WorkEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    contentCategory: contentCategory ?? this.contentCategory,
    isTranslation: isTranslation ?? this.isTranslation,
    language: language != null ? language.value : this.language,
    genre: genre != null ? genre.value : this.genre,
    originalTitle: originalTitle != null ? originalTitle.value : this.originalTitle,
    originalLanguage: originalLanguage != null ? originalLanguage.value : this.originalLanguage,
    notes: notes != null ? notes.value : this.notes,
    authorIds: authorIds ?? this.authorIds,
    translatorIds: translatorIds ?? this.translatorIds,
    sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
    bookId: bookId != null ? bookId.value : this.bookId,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
