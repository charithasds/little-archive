import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/reader_repository_impl.dart';
import '../domain/usecases/reader_usecases.dart';

export '../domain/usecases/reader_usecases.dart';

part 'reader_usecase_providers.g.dart';

@riverpod
GenerateReaderIdUseCase generateReaderIdUseCase(Ref ref) =>
    GenerateReaderIdUseCase(ref.watch(readerRepositoryProvider));

@riverpod
FetchReadersUseCase fetchReadersUseCase(Ref ref) =>
    FetchReadersUseCase(ref.watch(readerRepositoryProvider));

@riverpod
FetchReaderByIdUseCase fetchReaderByIdUseCase(Ref ref) =>
    FetchReaderByIdUseCase(ref.watch(readerRepositoryProvider));

@riverpod
WatchReadersUseCase watchReadersUseCase(Ref ref) =>
    WatchReadersUseCase(ref.watch(readerRepositoryProvider));

@riverpod
AddReaderUseCase addReaderUseCase(Ref ref) => AddReaderUseCase(ref.watch(readerRepositoryProvider));

@riverpod
EditReaderUseCase editReaderUseCase(Ref ref) =>
    EditReaderUseCase(ref.watch(readerRepositoryProvider));

@riverpod
RemoveReaderUseCase removeReaderUseCase(Ref ref) =>
    RemoveReaderUseCase(ref.watch(readerRepositoryProvider));
