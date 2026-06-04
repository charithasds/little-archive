import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/publisher_entity.dart';
import '../../domain/usecases/publisher_usecases.dart';

part 'publisher_provider.g.dart';

@riverpod
Stream<List<PublisherEntity>> publishersStream(Ref ref) {
  final WatchPublishersUseCase watchPublishers = ref.watch(watchPublishersUseCaseProvider);
  return watchPublishers();
}

@riverpod
Future<int> publisherCount(Ref ref) async {
  final List<PublisherEntity> publishers = await ref.watch(publishersStreamProvider.future);
  return publishers.length;
}

@riverpod
AsyncValue<PublisherEntity?> publisher(Ref ref, String id) {
  final AsyncValue<List<PublisherEntity>> stream = ref.watch(publishersStreamProvider);
  return stream.when(
    data: (List<PublisherEntity> list) {
      try {
        return AsyncValue<PublisherEntity?>.data(list.firstWhere((PublisherEntity p) => p.id == id));
      } catch (_) {
        return const AsyncValue<PublisherEntity?>.data(null);
      }
    },
    error: (Object e, StackTrace s) => AsyncValue<PublisherEntity?>.error(e, s),
    loading: () => const AsyncValue<PublisherEntity?>.loading(),
  );
}

// ── Publisher missing-info provider ─────────────────────────────────────

@riverpod
List<({String label, int count})>? publishersMissingInfo(Ref ref) {
  final List<PublisherEntity>? publishers = ref.watch(publishersStreamProvider).value;
  if (publishers == null) {
    return null;
  }

  int noAltName = 0;
  int noWebsite = 0;
  int noBooks = 0;

  for (final PublisherEntity p in publishers) {
    if (p.otherName == null || p.otherName!.trim().isEmpty) {
      noAltName++;
    }
    if (p.website == null || p.website!.trim().isEmpty) {
      noWebsite++;
    }
    if (p.bookIds.isEmpty) {
      noBooks++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Alt. Name', count: noAltName),
    (label: 'No Website', count: noWebsite),
    (label: 'No Books', count: noBooks),
  ];
}
