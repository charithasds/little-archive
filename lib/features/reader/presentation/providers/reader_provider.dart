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

  int countWhere(bool Function(ReaderEntity) test) => readers.where(test).length;

  return <({String label, int count})>[
    (
      label: 'No Photo',
      count: countWhere((ReaderEntity r) => r.image == null || r.image!.trim().isEmpty),
    ),
    (
      label: 'No Alt. Name',
      count: countWhere((ReaderEntity r) => r.otherName == null || r.otherName!.trim().isEmpty),
    ),
    (
      label: 'No Email',
      count: countWhere((ReaderEntity r) => r.email == null || r.email!.trim().isEmpty),
    ),
    (
      label: 'No Phone',
      count: countWhere((ReaderEntity r) => r.phoneNumber == null || r.phoneNumber!.trim().isEmpty),
    ),
    (label: 'No Books', count: countWhere((ReaderEntity r) => r.bookIds.isEmpty)),
  ];
}
