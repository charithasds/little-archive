import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
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
Future<int> publisherCount(Ref ref) async {
  final String? userId = ref.watch(currentUidProvider);
  if (userId == null) {
    return 0;
  }
  final FirebaseFirestore firestore = ref.watch(firestoreServiceProvider).firebaseFirestore;
  final AggregateQuerySnapshot snap = await firestore.collection('users/$userId/publishers').count().get();
  return snap.count ?? 0;
}


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

  int noLogo = 0;
  int noAltName = 0;
  int noWebsite = 0;
  int noEmail = 0;
  int noPhone = 0;
  int noBooks = 0;

  for (final PublisherEntity p in publishers) {
    if (p.logo == null || p.logo!.trim().isEmpty) {
      noLogo++;
    }
    if (p.otherName == null || p.otherName!.trim().isEmpty) {
      noAltName++;
    }
    if (p.website == null || p.website!.trim().isEmpty) {
      noWebsite++;
    }
    if (p.email == null || p.email!.trim().isEmpty) {
      noEmail++;
    }
    if (p.phoneNumber == null || p.phoneNumber!.trim().isEmpty) {
      noPhone++;
    }
    if (p.bookIds.isEmpty) {
      noBooks++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Logo', count: noLogo),
    (label: 'No Alt. Name', count: noAltName),
    (label: 'No Website', count: noWebsite),
    (label: 'No Email', count: noEmail),
    (label: 'No Phone', count: noPhone),
    (label: 'No Books', count: noBooks),
  ];
}
