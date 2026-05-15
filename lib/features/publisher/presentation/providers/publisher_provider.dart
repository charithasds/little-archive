import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/usecases/publisher_usecases.dart';

part 'publisher_provider.g.dart';

@riverpod
Stream<List<PublisherEntity>> publishersStream(Ref ref) {
  final WatchPublishersUseCase watchPublishers = ref.watch(watchPublishersUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<PublisherEntity>>.value(<PublisherEntity>[]);
  }

  return watchPublishers();
}

@riverpod
int? publisherCount(Ref ref) => ref.watch(publishersStreamProvider).value?.length;

@riverpod
Future<PublisherEntity?> publisher(Ref ref, String id) async {
  final List<PublisherEntity> publishers = await ref.watch(publishersStreamProvider.future);

  try {
    return publishers.firstWhere((PublisherEntity p) => p.id == id);
  } catch (_) {
    return null;
  }
}

// ── Publisher missing-info provider ───────────────────────────────────

@riverpod
List<({String label, int count})>? publishersMissingInfo(Ref ref) {
  final List<PublisherEntity>? publishers = ref.watch(publishersStreamProvider).value;
  if (publishers == null) {
    return null;
  }

  int countWhere(bool Function(PublisherEntity) test) => publishers.where(test).length;

  return <({String label, int count})>[
    (
      label: 'No Logo',
      count: countWhere((PublisherEntity p) => p.logo == null || p.logo!.trim().isEmpty),
    ),
    (
      label: 'No Alt. Name',
      count: countWhere((PublisherEntity p) => p.otherName == null || p.otherName!.trim().isEmpty),
    ),
    (
      label: 'No Website',
      count: countWhere((PublisherEntity p) => p.website == null || p.website!.trim().isEmpty),
    ),
    (
      label: 'No Email',
      count: countWhere((PublisherEntity p) => p.email == null || p.email!.trim().isEmpty),
    ),
    (
      label: 'No Phone',
      count: countWhere(
        (PublisherEntity p) => p.phoneNumber == null || p.phoneNumber!.trim().isEmpty,
      ),
    ),
    (label: 'No Books', count: countWhere((PublisherEntity p) => p.bookIds.isEmpty)),
  ];
}
