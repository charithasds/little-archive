import '../entities/publisher_entity.dart';
import '../repositories/publisher_repository.dart';

class GetPublishersUseCase {
  const GetPublishersUseCase(this.repository);
  final PublisherRepository repository;

  Future<List<PublisherEntity>> call(String userId) => repository.getPublishers(userId);
}

class WatchPublishersUseCase {
  const WatchPublishersUseCase(this.repository);
  final PublisherRepository repository;

  Stream<List<PublisherEntity>> call(String userId) => repository.watchPublishers(userId);
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

class UpdatePublisherUseCase {
  const UpdatePublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(PublisherEntity publisher) => repository.updatePublisher(publisher);
}

class DeletePublisherUseCase {
  const DeletePublisherUseCase(this.repository);
  final PublisherRepository repository;

  Future<void> call(String id) => repository.deletePublisher(id);
}
