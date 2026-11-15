import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/work_repository_impl.dart';
import '../domain/usecases/work_usecases.dart';

export '../domain/usecases/work_usecases.dart';

part 'work_usecase_providers.g.dart';

@riverpod
GenerateWorkIdUseCase generateWorkIdUseCase(Ref ref) =>
    GenerateWorkIdUseCase(ref.watch(workRepositoryProvider));

@riverpod
FetchWorksUseCase fetchWorksUseCase(Ref ref) =>
    FetchWorksUseCase(ref.watch(workRepositoryProvider));

@riverpod
FetchWorkByIdUseCase fetchWorkByIdUseCase(Ref ref) =>
    FetchWorkByIdUseCase(ref.watch(workRepositoryProvider));

@riverpod
WatchWorksUseCase watchWorksUseCase(Ref ref) =>
    WatchWorksUseCase(ref.watch(workRepositoryProvider));

@riverpod
AddWorkUseCase addWorkUseCase(Ref ref) => AddWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
EditWorkUseCase editWorkUseCase(Ref ref) => EditWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
RemoveWorkUseCase removeWorkUseCase(Ref ref) =>
    RemoveWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
UpsertWorkUseCase upsertWorkUseCase(Ref ref) =>
    UpsertWorkUseCase(ref.watch(workRepositoryProvider));
