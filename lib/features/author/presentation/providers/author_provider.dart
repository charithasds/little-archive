import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/usecases/author_usecases.dart';

part 'author_provider.g.dart';

@riverpod
Stream<List<AuthorEntity>> authorsStream(Ref ref) {
  final WatchAuthorsUseCase watchAuthors = ref.watch(watchAuthorsUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<AuthorEntity>>.value(<AuthorEntity>[]);
  }

  return watchAuthors();
}


@riverpod
Future<int> authorCount(Ref ref) async {
  final String? userId = ref.watch(currentUidProvider);
  if (userId == null) {
    return 0;
  }
  final FirebaseFirestore firestore = ref.watch(firestoreServiceProvider).firebaseFirestore;
  final AggregateQuerySnapshot snap = await firestore.collection('users/$userId/authors').count().get();
  return snap.count ?? 0;
}

@riverpod
Future<AuthorEntity?> author(Ref ref, String id) async {
  final List<AuthorEntity> authors = await ref.watch(authorsStreamProvider.future);

  try {
    return authors.firstWhere((AuthorEntity a) => a.id == id);
  } catch (_) {
    return null;
  }
}

// ── Author missing-info provider ─────────────────────────────────────────

@riverpod
List<({String label, int count})>? authorsMissingInfo(Ref ref) {
  final List<AuthorEntity>? authors = ref.watch(authorsStreamProvider).value;
  if (authors == null) {
    return null;
  }

  int noPhoto = 0;
  int noAltName = 0;
  int noWebsite = 0;
  int noBooks = 0;
  int noWorks = 0;

  for (final AuthorEntity a in authors) {
    if (a.image == null || a.image!.trim().isEmpty) {
      noPhoto++;
    }
    if (a.otherName == null || a.otherName!.trim().isEmpty) {
      noAltName++;
    }
    if (a.website == null || a.website!.trim().isEmpty) {
      noWebsite++;
    }
    if (a.bookIds.isEmpty) {
      noBooks++;
    }
    if (a.workIds.isEmpty) {
      noWorks++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Photo', count: noPhoto),
    (label: 'No Alt. Name', count: noAltName),
    (label: 'No Website', count: noWebsite),
    (label: 'No Books', count: noBooks),
    (label: 'No Works', count: noWorks),
  ];
}
