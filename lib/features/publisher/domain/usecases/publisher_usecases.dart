import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/publisher_repository_impl.dart';
import '../entities/publisher_entity.dart';
import '../repositories/publisher_repository.dart';

part 'publisher_usecases.g.dart';

class GeneratePublisherIdUseCase {
  const GeneratePublisherIdUseCase(this.repository);
  final PublisherRepository repository;

  String call() => repository.generateId();
}

class FetchPublishersUseCase {
  const FetchPublishersUseCase(this.repository);
  final PublisherRepository repository;

  Future<List<PublisherEntity>> call() => repository.fetchPublishers();
}

class FetchPublisherByIdUseCase {
  const FetchPublisherByIdUseCase(this.repository);
  final PublisherRepository repository;

  Future<PublisherEntity?> call(String id) => repository.fetchPublisherById(id);
}

class WatchPublishersUseCase {
  const WatchPublishersUseCase(this.repository);
  final PublisherRepository repository;

  Stream<List<PublisherEntity>> call() => repository.watchPublishers();
}

class AddPublisherUseCase {
  const AddPublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(PublisherEntity publisher) => repository.addPublisher(publisher);
}

class EditPublisherUseCase {
  const EditPublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(PublisherEntity publisher, {PublisherEntity? oldPublisher}) =>
      repository.editPublisher(publisher, oldPublisher: oldPublisher);
}

class RemovePublisherUseCase {
  const RemovePublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(String id) => repository.removePublisher(id);
}

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
