import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/sequence_volume_repository_impl.dart';
import '../domain/usecases/sequence_volume_usecases.dart';

export '../domain/usecases/sequence_volume_usecases.dart';

part 'sequence_volume_usecase_providers.g.dart';

@riverpod
GenerateSequenceVolumeIdUseCase generateSequenceVolumeIdUseCase(Ref ref) =>
    GenerateSequenceVolumeIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumesUseCase fetchSequenceVolumesUseCase(Ref ref) =>
    FetchSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumeByIdUseCase fetchSequenceVolumeByIdUseCase(Ref ref) =>
    FetchSequenceVolumeByIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumesByBookIdUseCase fetchSequenceVolumesByBookIdUseCase(Ref ref) =>
    FetchSequenceVolumesByBookIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumesByWorkIdUseCase fetchSequenceVolumesByWorkIdUseCase(Ref ref) =>
    FetchSequenceVolumesByWorkIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
WatchSequenceVolumesUseCase watchSequenceVolumesUseCase(Ref ref) =>
    WatchSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
WatchAllSequenceVolumesUseCase watchAllSequenceVolumesUseCase(Ref ref) =>
    WatchAllSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
AddSequenceVolumeUseCase addSequenceVolumeUseCase(Ref ref) =>
    AddSequenceVolumeUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
EditSequenceVolumeUseCase editSequenceVolumeUseCase(Ref ref) =>
    EditSequenceVolumeUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
RemoveSequenceVolumeUseCase removeSequenceVolumeUseCase(Ref ref) =>
    RemoveSequenceVolumeUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
SyncBookSequenceVolumesUseCase syncBookSequenceVolumesUseCase(Ref ref) =>
    SyncBookSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
SyncWorkSequenceVolumesUseCase syncWorkSequenceVolumesUseCase(Ref ref) =>
    SyncWorkSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));
