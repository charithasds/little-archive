import '../entities/translator_entity.dart';
import '../repositories/translator_repository.dart';

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
