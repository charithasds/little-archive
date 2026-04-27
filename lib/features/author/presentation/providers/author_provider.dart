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
Future<AuthorEntity?> author(Ref ref, String id) async {
  final List<AuthorEntity> authors = await ref.watch(authorsStreamProvider.future);

  try {
    return authors.firstWhere((AuthorEntity a) => a.id == id);
  } catch (_) {
    return null;
  }
}
