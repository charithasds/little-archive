import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/reader_entity.dart';
import '../../domain/usecases/reader_usecases.dart';

part 'reader_provider.g.dart';

@riverpod
Stream<List<ReaderEntity>> readersStream(Ref ref) {
  final WatchReadersUseCase watchReaders = ref.watch(watchReadersUseCaseProvider);
  return watchReaders();
}

@riverpod
Future<int> readerCount(Ref ref) async {
  final List<ReaderEntity> readers = await ref.watch(readersStreamProvider.future);
  return readers.length;
}

@riverpod
AsyncValue<ReaderEntity?> reader(Ref ref, String id) {
  final AsyncValue<List<ReaderEntity>> stream = ref.watch(readersStreamProvider);
  return stream.when(
    data: (List<ReaderEntity> list) {
      try {
        return AsyncValue<ReaderEntity?>.data(list.firstWhere((ReaderEntity r) => r.id == id));
      } catch (_) {
        return const AsyncValue<ReaderEntity?>.data(null);
      }
    },
    error: (Object e, StackTrace s) => AsyncValue<ReaderEntity?>.error(e, s),
    loading: () => const AsyncValue<ReaderEntity?>.loading(),
  );
}

// ── Reader missing-info provider ─────────────────────────────────────

@riverpod
List<({String label, int count})>? readersMissingInfo(Ref ref) {
  final List<ReaderEntity>? readers = ref.watch(readersStreamProvider).value;
  if (readers == null) {
    return null;
  }

  int noPhoto = 0;
  int noAltName = 0;
  int noBooks = 0;

  for (final ReaderEntity r in readers) {
    if (r.image == null || r.image!.trim().isEmpty) {
      noPhoto++;
    }
    if (r.otherName == null || r.otherName!.trim().isEmpty) {
      noAltName++;
    }
    if (r.bookIds.isEmpty) {
      noBooks++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Photo', count: noPhoto),
    (label: 'No Alt. Name', count: noAltName),
    (label: 'No Books', count: noBooks),
  ];
}
