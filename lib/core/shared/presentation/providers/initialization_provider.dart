import 'package:firebase_core/firebase_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../firebase_options.dart';
import 'shared_preferences_provider.dart';

part 'initialization_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> initialization(Ref ref) async {
  final Future<void> prefsFuture = ref.watch(sharedPreferencesProvider.future);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  await prefsFuture;
}
