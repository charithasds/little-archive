import '../entities/translator_entity.dart';
import '../repositories/translator_repository.dart';

class GetTranslatorsUseCase {
  const GetTranslatorsUseCase(this.repository);
  final TranslatorRepository repository;

  Future<List<TranslatorEntity>> call(String userId) => repository.getTranslators(userId);
}

class WatchTranslatorsUseCase {
  const WatchTranslatorsUseCase(this.repository);
  final TranslatorRepository repository;

  Stream<List<TranslatorEntity>> call(String userId) => repository.watchTranslators(userId);
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

class UpdateTranslatorUseCase {
  const UpdateTranslatorUseCase(this.repository);
  final TranslatorRepository repository;

  Future<void> call(TranslatorEntity translator) => repository.updateTranslator(translator);
}

class DeleteTranslatorUseCase {
  const DeleteTranslatorUseCase(this.repository);
  final TranslatorRepository repository;

  Future<void> call(String id) => repository.deleteTranslator(id);
}
