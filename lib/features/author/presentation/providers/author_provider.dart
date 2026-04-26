import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/usecases/author_usecases.dart';

part 'author_provider.g.dart';

@riverpod
Stream<List<AuthorEntity>> authorsStream(Ref ref) {
  final WatchAuthorsUseCase watchAuthors = ref.watch(watchAuthorsUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<AuthorEntity>>.value(<AuthorEntity>[]);
  }

  return watchAuthors();
}

@riverpod
int? authorCount(Ref ref) => ref.watch(authorsStreamProvider).value?.length;

@riverpod
Future<String?> authorName(Ref ref, String id) async {
  final FetchAuthorByIdUseCase fetchAuthor = ref.watch(fetchAuthorByIdUseCaseProvider);
  final AuthorEntity? author = await fetchAuthor(id);
  return author?.name;
}
