import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../datasources/author_remote_datasource.dart';
import '../models/author_model.dart';

part 'author_repository_impl.g.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  AuthorRepositoryImpl({required this.remoteDataSource});

  final AuthorRemoteDataSource remoteDataSource;

  final Set<String> _processedImageAuthorIds = <String>{};

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<AuthorEntity>> fetchAuthors() async {
    final List<AuthorEntity> authors = await remoteDataSource.fetchAuthors();
    _compressExistingLargeImages(authors);
    return authors;
  }

  void _compressExistingLargeImages(List<AuthorEntity> authors) {
    Future<void>.microtask(() async {
      for (final AuthorEntity author in authors) {
        if (_processedImageAuthorIds.contains(author.id)) {
          continue;
        }
        _processedImageAuthorIds.add(author.id);

        final String? image = author.image;
        if (image != null && image.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(image);
          if (compressed != null && compressed != image) {
            final AuthorEntity updated = author.copyWith(
              image: Nullable<String?>(compressed),
              lastUpdated: DateTime.now(),
            );
            await editAuthor(updated);
          }
        }
      }
    });
  }

  @override
  Future<AuthorEntity?> fetchAuthorById(String id) => remoteDataSource.fetchAuthorById(id);

  @override
  Stream<List<AuthorEntity>> watchAuthors() => remoteDataSource.watchAuthors();

  @override
  Future<void> addAuthor(AuthorEntity author) async {
    await remoteDataSource.addAuthor(
      AuthorModel(
        id: author.id,
        name: author.name,
        image: Images.compressImageIfNeeded(author.image),
        otherName: author.otherName,
        website: author.website,
        facebook: author.facebook,
        bookIds: author.bookIds,
        workIds: author.workIds,
        createdDate: author.createdDate,
        lastUpdated: author.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editAuthor(AuthorEntity author, {AuthorEntity? oldAuthor}) async {
    await remoteDataSource.editAuthor(
      AuthorModel(
        id: author.id,
        name: author.name,
        image: Images.compressImageIfNeeded(author.image),
        otherName: author.otherName,
        website: author.website,
        facebook: author.facebook,
        bookIds: author.bookIds,
        workIds: author.workIds,
        createdDate: author.createdDate,
        lastUpdated: author.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removeAuthor(String id) async {
    await remoteDataSource.removeAuthor(id);
  }
}

@riverpod
AuthorRepository authorRepository(Ref ref) {
  final AuthorRemoteDataSource remoteDataSource = ref.watch(authorRemoteDataSourceProvider);

  return AuthorRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
