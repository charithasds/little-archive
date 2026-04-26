import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/usecases/publisher_usecases.dart';

part 'publisher_provider.g.dart';

@riverpod
Stream<List<PublisherEntity>> publishersStream(Ref ref) {
  final WatchPublishersUseCase watchPublishers = ref.watch(watchPublishersUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<PublisherEntity>>.value(<PublisherEntity>[]);
  }

  return watchPublishers();
}

@riverpod
int? publisherCount(Ref ref) => ref.watch(publishersStreamProvider).value?.length;
