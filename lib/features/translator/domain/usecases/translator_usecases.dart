import '../entities/translator_entity.dart';
import '../repositories/translator_repository.dart';

class GetTranslatorsUseCase {
  const GetTranslatorsUseCase(this.repository);
  final TranslatorRepository repository;

  Future<List<TranslatorEntity>> call() => repository.getTranslators();
}

class WatchTranslatorsUseCase {
  const WatchTranslatorsUseCase(this.repository);
  final TranslatorRepository repository;

  Stream<List<TranslatorEntity>> call() => repository.watchTranslators();
}

class GetTranslatorByIdUseCase {
  const GetTranslatorByIdUseCase(this.repository);
  final TranslatorRepository repository;

  Future<TranslatorEntity?> call(String id) => repository.getTranslatorById(id);
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
