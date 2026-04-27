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
