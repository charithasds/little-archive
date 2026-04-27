import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';

part 'work_provider.g.dart';

@riverpod
Stream<List<WorkEntity>> worksStream(Ref ref) {
  final WatchWorksUseCase watchWorks = ref.watch(watchWorksUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<WorkEntity>>.value(<WorkEntity>[]);
  }

  return watchWorks();
}

@riverpod
int? workCount(Ref ref) => ref.watch(worksStreamProvider).value?.length;

@riverpod
Future<WorkEntity?> work(Ref ref, String id) async {
  final List<WorkEntity> works = await ref.watch(worksStreamProvider.future);

  try {
    return works.firstWhere((WorkEntity w) => w.id == id);
  } catch (_) {
    return null;
  }
}
