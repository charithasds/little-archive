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
Future<int> workCount(Ref ref) async {
  final FetchWorkCountUseCase fetchWorkCount = ref.watch(fetchWorkCountUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return 0;
  }

  return fetchWorkCount();
}
