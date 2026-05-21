import '../../../publisher/domain/entities/publisher_entity.dart';
import 'book_fair_stall_suggestion.dart';

class PublisherStallSuggestions {
  const PublisherStallSuggestions({required this.publisher, required this.suggestions});

  final PublisherEntity publisher;
  final List<BookFairStallSuggestion> suggestions;
}
