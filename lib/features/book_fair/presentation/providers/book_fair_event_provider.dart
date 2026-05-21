import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/usecases/get_book_fair_event_usecase.dart';

part 'book_fair_event_provider.g.dart';

@riverpod
Future<BookFairEventEntity> bookFairEvent(Ref ref) =>
    ref.watch(getBookFairEventUseCaseProvider).call();
