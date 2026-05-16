import 'package:equatable/equatable.dart';
import '../book_entity.dart';
import 'scanned_name_entity.dart';

class ScannedBookEntity extends Equatable {
  const ScannedBookEntity({
    required this.book,
    this.authors = const <ScannedNameEntity>[],
    this.translators = const <ScannedNameEntity>[],
    this.publisher,
    this.analysisError,
  });

  final BookEntity book;
  final List<ScannedNameEntity> authors;
  final List<ScannedNameEntity> translators;
  final ScannedNameEntity? publisher;
  final String? analysisError;

  @override
  List<Object?> get props => <Object?>[book, authors, translators, publisher, analysisError];
}
