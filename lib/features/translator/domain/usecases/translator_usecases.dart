import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/translator_repository_impl.dart';
import '../entities/translator_entity.dart';
import '../repositories/translator_repository.dart';

part 'translator_usecases.g.dart';

class GenerateTranslatorIdUseCase {
  const GenerateTranslatorIdUseCase(this.repository);
  final TranslatorRepository repository;

  String call() => repository.generateId();
}

class FetchTranslatorsUseCase {
  const FetchTranslatorsUseCase(this.repository);
  final TranslatorRepository repository;

  Future<List<TranslatorEntity>> call() => repository.fetchTranslators();
}

class FetchTranslatorByIdUseCase {
  const FetchTranslatorByIdUseCase(this.repository);
  final TranslatorRepository repository;

  Future<TranslatorEntity?> call(String id) => repository.fetchTranslatorById(id);
}

class WatchTranslatorsUseCase {
  const WatchTranslatorsUseCase(this.repository);
  final TranslatorRepository repository;

  Stream<List<TranslatorEntity>> call() => repository.watchTranslators();
}

class FetchTranslatorCountUseCase {
  const FetchTranslatorCountUseCase(this.repository);
  final TranslatorRepository repository;

  Future<int> call() => repository.fetchCount();
}

class AddTranslatorUseCase {
  const AddTranslatorUseCase(this.repository);
  final TranslatorRepository repository;

  Future<void> call(TranslatorEntity translator) => repository.addTranslator(translator);
}

class EditTranslatorUseCase {
  const EditTranslatorUseCase(this.repository);
  final TranslatorRepository repository;

  Future<void> call(TranslatorEntity translator) => repository.editTranslator(translator);
}

class RemoveTranslatorUseCase {
  const RemoveTranslatorUseCase(this.repository);
  final TranslatorRepository repository;

  Future<void> call(String id) => repository.removeTranslator(id);
}

@riverpod
GenerateTranslatorIdUseCase generateTranslatorIdUseCase(Ref ref) =>
    GenerateTranslatorIdUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
FetchTranslatorsUseCase fetchTranslatorsUseCase(Ref ref) =>
    FetchTranslatorsUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
FetchTranslatorByIdUseCase fetchTranslatorByIdUseCase(Ref ref) =>
    FetchTranslatorByIdUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
WatchTranslatorsUseCase watchTranslatorsUseCase(Ref ref) =>
    WatchTranslatorsUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
FetchTranslatorCountUseCase fetchTranslatorCountUseCase(Ref ref) =>
    FetchTranslatorCountUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
AddTranslatorUseCase addTranslatorUseCase(Ref ref) =>
    AddTranslatorUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
EditTranslatorUseCase editTranslatorUseCase(Ref ref) =>
    EditTranslatorUseCase(ref.watch(translatorRepositoryProvider));

@riverpod
RemoveTranslatorUseCase removeTranslatorUseCase(Ref ref) =>
    RemoveTranslatorUseCase(ref.watch(translatorRepositoryProvider));
