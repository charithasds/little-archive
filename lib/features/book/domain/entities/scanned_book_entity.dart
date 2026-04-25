import 'package:equatable/equatable.dart';

import 'book_entity.dart';

class ScannedBookEntity extends Equatable {
  const ScannedBookEntity({
    required this.book,
    this.authorNames = const <String>[],
    this.translatorNames = const <String>[],
    this.publisherName,
  });

  final BookEntity book;
  final List<String> authorNames;
  final List<String> translatorNames;
  final String? publisherName;

  @override
  List<Object?> get props => <Object?>[book, authorNames, translatorNames, publisherName];
}
