import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/usecases/reader_usecases.dart';

part 'reader_provider.g.dart';

@riverpod
Stream<List<ReaderEntity>> readersStream(Ref ref) {
  final WatchReadersUseCase watchReaders = ref.watch(watchReadersUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<ReaderEntity>>.value(<ReaderEntity>[]);
  }

  return watchReaders();
}

@riverpod
int? readerCount(Ref ref) => ref.watch(readersStreamProvider).value?.length;

@riverpod
Future<ReaderEntity?> reader(Ref ref, String id) async {
  final List<ReaderEntity> readers = await ref.watch(readersStreamProvider.future);

  try {
    return readers.firstWhere((ReaderEntity r) => r.id == id);
  } catch (_) {
    return null;
  }
}

// ── Reader missing-info provider ─────────────────────────────────────────

@riverpod
List<({String label, int count})>? readersMissingInfo(Ref ref) {
  final List<ReaderEntity>? readers = ref.watch(readersStreamProvider).value;
  if (readers == null) {
    return null;
  }

  int noPhoto = 0;
  int noAltName = 0;
  int noEmail = 0;
  int noPhone = 0;
  int noBooks = 0;

  for (final ReaderEntity r in readers) {
    if (r.image == null || r.image!.trim().isEmpty) {
      noPhoto++;
    }
    if (r.otherName == null || r.otherName!.trim().isEmpty) {
      noAltName++;
    }
    if (r.email == null || r.email!.trim().isEmpty) {
      noEmail++;
    }
    if (r.phoneNumber == null || r.phoneNumber!.trim().isEmpty) {
      noPhone++;
    }
    if (r.bookIds.isEmpty) {
      noBooks++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Photo', count: noPhoto),
    (label: 'No Alt. Name', count: noAltName),
    (label: 'No Email', count: noEmail),
    (label: 'No Phone', count: noPhone),
    (label: 'No Books', count: noBooks),
  ];
}
