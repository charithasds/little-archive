import '../entities/publisher_entity.dart';
import '../repositories/publisher_repository.dart';

class GetPublishersUseCase {
  const GetPublishersUseCase(this.repository);
  final PublisherRepository repository;

  Future<List<PublisherEntity>> call() => repository.getPublishers();
}

class WatchPublishersUseCase {
  const WatchPublishersUseCase(this.repository);
  final PublisherRepository repository;

  Stream<List<PublisherEntity>> call() => repository.watchPublishers();
}

class GetPublisherByIdUseCase {
  const GetPublisherByIdUseCase(this.repository);
  final PublisherRepository repository;

  Future<PublisherEntity?> call(String id) => repository.getPublisherById(id);
}

class AddPublisherUseCase {
  const AddPublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(PublisherEntity publisher) => repository.addPublisher(publisher);
}

class EditPublisherUseCase {
  const EditPublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(PublisherEntity publisher) => repository.editPublisher(publisher);
}

class RemovePublisherUseCase {
  const RemovePublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(String id) => repository.removePublisher(id);
}
