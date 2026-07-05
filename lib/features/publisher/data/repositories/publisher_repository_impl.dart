import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../datasources/publisher_remote_datasource.dart';
import '../models/publisher_model.dart';

part 'publisher_repository_impl.g.dart';

class PublisherRepositoryImpl implements PublisherRepository {
  PublisherRepositoryImpl({required this.remoteDataSource});

  final PublisherRemoteDataSource remoteDataSource;

  final Set<String> _processedLogoPublisherIds = <String>{};

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<PublisherEntity>> fetchPublishers() async {
    final List<PublisherEntity> publishers = await remoteDataSource.fetchPublishers();
    _compressExistingLargeLogos(publishers);
    return publishers;
  }

  void _compressExistingLargeLogos(List<PublisherEntity> publishers) {
    Future<void>.microtask(() async {
      for (final PublisherEntity publisher in publishers) {
        if (_processedLogoPublisherIds.contains(publisher.id)) {
          continue;
        }
        _processedLogoPublisherIds.add(publisher.id);

        final String? logo = publisher.logo;
        if (logo != null && logo.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(logo);
          if (compressed != null && compressed != logo) {
            final PublisherEntity updated = publisher.copyWith(
              logo: Nullable<String?>(compressed),
              lastUpdated: DateTime.now(),
            );
            await editPublisher(updated);
          }
        }
      }
    });
  }

  @override
  Future<PublisherEntity?> fetchPublisherById(String id) => remoteDataSource.fetchPublisherById(id);

  @override
  Stream<List<PublisherEntity>> watchPublishers() => remoteDataSource.watchPublishers();

  @override
  Future<void> addPublisher(PublisherEntity publisher) async {
    await remoteDataSource.addPublisher(
      PublisherModel(
        id: publisher.id,
        name: publisher.name,
        isSelfPublisher: publisher.isSelfPublisher,
        logo: publisher.logo,
        otherName: publisher.otherName,
        website: publisher.website,
        email: publisher.email,
        facebook: publisher.facebook,
        phoneNumber: publisher.phoneNumber,
        bookIds: publisher.bookIds,
        bookFairPublisherId: publisher.bookFairPublisherId,
        createdDate: publisher.createdDate,
        lastUpdated: publisher.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editPublisher(PublisherEntity publisher, {PublisherEntity? oldPublisher}) async {
    await remoteDataSource.editPublisher(
      PublisherModel(
        id: publisher.id,
        name: publisher.name,
        isSelfPublisher: publisher.isSelfPublisher,
        logo: publisher.logo,
        otherName: publisher.otherName,
        website: publisher.website,
        email: publisher.email,
        facebook: publisher.facebook,
        phoneNumber: publisher.phoneNumber,
        bookIds: publisher.bookIds,
        bookFairPublisherId: publisher.bookFairPublisherId,
        createdDate: publisher.createdDate,
        lastUpdated: publisher.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removePublisher(String id) async {
    await remoteDataSource.removePublisher(id);
  }
}

@riverpod
PublisherRepository publisherRepository(Ref ref) {
  final PublisherRemoteDataSource remoteDataSource = ref.watch(publisherRemoteDataSourceProvider);

  return PublisherRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
