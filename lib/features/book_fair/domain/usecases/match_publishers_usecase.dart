import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../publisher/domain/entities/publisher_entity.dart';
import '../entities/book_fair_event_entity.dart';
import '../entities/book_fair_stall_entity.dart';
import '../entities/book_fair_stall_suggestion.dart';
import '../entities/publisher_stall_suggestions.dart';

part 'match_publishers_usecase.g.dart';

class MatchPublishersUseCase {
  const MatchPublishersUseCase();

  BookFairStallEntity? findBestSuggestion(
    PublisherEntity publisher,
    List<BookFairStallEntity> bookfairStalls,
  ) {
    BookFairStallEntity? bestBookFairStall;
    double highestScore = 0.05;

    for (final BookFairStallEntity bookfairStall in bookfairStalls) {
      double score = _calculateSimilarity(publisher.name, bookfairStall.name);

      if (publisher.otherName != null && publisher.otherName!.trim().isNotEmpty) {
        final double otherScore = _calculateSimilarity(publisher.otherName!, bookfairStall.name);

        if (otherScore > score) {
          score = otherScore;
        }
      }

      if (score > highestScore) {
        highestScore = score;
        bestBookFairStall = bookfairStall;
      }
    }

    return bestBookFairStall;
  }

  double _calculateSimilarity(String s1, String s2) {
    final String a = s1.toLowerCase().trim();
    final String b = s2.toLowerCase().trim();

    if (a == b) {
      return 1.0;
    }

    if (a.isEmpty || b.isEmpty) {
      return 0.0;
    }

    if (a.contains(b) || b.contains(a)) {
      return 0.8 + (0.2 * (a.length < b.length ? a.length / b.length : b.length / a.length));
    }

    final Set<String> wordsA = a.split(RegExp(r'\s+')).toSet();
    final Set<String> wordsB = b.split(RegExp(r'\s+')).toSet();
    final int intersection = wordsA.intersection(wordsB).length;

    if (intersection > 0) {
      return 0.5 +
          (0.3 * (intersection / (wordsA.length > wordsB.length ? wordsA.length : wordsB.length)));
    }

    final int distance = _levenshtein(a, b);
    final int maxLength = a.length > b.length ? a.length : b.length;

    return 1.0 - (distance / maxLength);
  }

  int _levenshtein(String s, String t) {
    if (s == t) {
      return 0;
    }

    if (s.isEmpty) {
      return t.length;
    }

    if (t.isEmpty) {
      return s.length;
    }

    final List<int> v0 = List<int>.generate(t.length + 1, (int i) => i);
    final List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        final int cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;

        v1[j + 1] = _min3(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v0[t.length];
  }

  int _min3(int a, int b, int c) {
    int m = a;

    if (b < m) {
      m = b;
    }

    if (c < m) {
      m = c;
    }

    return m;
  }

  List<PublisherStallSuggestions> matchPublishers({
    required List<PublisherEntity> publishers,
    required BookFairEventEntity event,
  }) {
    final List<PublisherStallSuggestions> publisherStallSuggestionsList =
        <PublisherStallSuggestions>[];

    for (final PublisherEntity publisher in publishers) {
      final String? mappingId = publisher.bookFairPublisherId;
      final bool isMapped = mappingId != null && mappingId.startsWith('CIBF_${event.year}_');

      if (!isMapped) {
        final List<BookFairStallSuggestion> bookFairStallSuggestions = <BookFairStallSuggestion>[];

        for (final BookFairStallEntity bookFairStall in event.stalls) {
          double score = _calculateSimilarity(publisher.name, bookFairStall.name);

          if (publisher.otherName != null && publisher.otherName!.trim().isNotEmpty) {
            final double otherScore = _calculateSimilarity(
              publisher.otherName!,
              bookFairStall.name,
            );

            if (otherScore > score) {
              score = otherScore;
            }
          }

          if (score > 0.05) {
            bookFairStallSuggestions.add(
              BookFairStallSuggestion(stall: bookFairStall, confidence: score),
            );
          }
        }

        bookFairStallSuggestions.sort(
          (BookFairStallSuggestion a, BookFairStallSuggestion b) =>
              b.confidence.compareTo(a.confidence),
        );

        final List<BookFairStallSuggestion> topSuggestions = bookFairStallSuggestions
            .take(3)
            .toList();

        publisherStallSuggestionsList.add(
          PublisherStallSuggestions(publisher: publisher, suggestions: topSuggestions),
        );
      }
    }

    return publisherStallSuggestionsList;
  }
}

@riverpod
MatchPublishersUseCase matchPublishersUseCase(Ref ref) => const MatchPublishersUseCase();
