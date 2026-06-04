import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/shared/presentation/providers/shared_preferences_provider.dart';

import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/usecases/get_book_fair_event_usecase.dart';

part 'book_fair_event_provider.g.dart';

@riverpod
Future<BookFairEventEntity> bookFairEvent(Ref ref) =>
    ref.watch(getBookFairEventUseCaseProvider).call();

@riverpod
class LastConfiguredFairId extends _$LastConfiguredFairId {
  @override
  String? build() {
    final SharedPreferences? prefs = ref.watch(sharedPreferencesProvider).value;
    return prefs?.getString('last_configured_fair_id');
  }

  Future<void> update(String? fairId) async {
    final SharedPreferences? prefs = ref.read(sharedPreferencesProvider).value;
    if (prefs != null) {
      if (fairId == null) {
        await prefs.remove('last_configured_fair_id');
      } else {
        await prefs.setString('last_configured_fair_id', fairId);
      }
      ref.invalidateSelf();
    }
  }
}
