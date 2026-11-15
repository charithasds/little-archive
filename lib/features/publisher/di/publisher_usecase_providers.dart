import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/publisher_repository_impl.dart';
import '../domain/usecases/publisher_usecases.dart';

export '../domain/usecases/publisher_usecases.dart';

part 'publisher_usecase_providers.g.dart';

@riverpod
GeneratePublisherIdUseCase generatePublisherIdUseCase(Ref ref) =>
    GeneratePublisherIdUseCase(ref.watch(publisherRepositoryProvider));

@riverpod
FetchPublishersUseCase fetchPublishersUseCase(Ref ref) =>
    FetchPublishersUseCase(ref.watch(publisherRepositoryProvider));

@riverpod
FetchPublisherByIdUseCase fetchPublisherByIdUseCase(Ref ref) =>
    FetchPublisherByIdUseCase(ref.watch(publisherRepositoryProvider));

@riverpod
WatchPublishersUseCase watchPublishersUseCase(Ref ref) =>
    WatchPublishersUseCase(ref.watch(publisherRepositoryProvider));

@riverpod
AddPublisherUseCase addPublisherUseCase(Ref ref) =>
    AddPublisherUseCase(ref.watch(publisherRepositoryProvider));

@riverpod
EditPublisherUseCase editPublisherUseCase(Ref ref) =>
    EditPublisherUseCase(ref.watch(publisherRepositoryProvider));

@riverpod
RemovePublisherUseCase removePublisherUseCase(Ref ref) =>
    RemovePublisherUseCase(ref.watch(publisherRepositoryProvider));
