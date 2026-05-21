import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/entities/publisher_stall_suggestions.dart';
import '../../domain/usecases/match_publishers_usecase.dart';
import 'book_fair_event_provider.dart';

part 'book_fair_suggestions_provider.g.dart';

@riverpod
Future<List<PublisherStallSuggestions>> publisherStallSuggestions(Ref ref) async {
  final List<PublisherEntity> publishers =
      ref.watch(publishersStreamProvider).value ?? <PublisherEntity>[];
  final BookFairEventEntity bookFairEvent = await ref.watch(bookFairEventProvider.future);
  final MatchPublishersUseCase matchPublishersUseCase = ref.watch(matchPublishersUseCaseProvider);

  return matchPublishersUseCase.matchPublishers(publishers: publishers, event: bookFairEvent);
}
