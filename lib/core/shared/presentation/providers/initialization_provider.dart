import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../firebase_options.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/shared_preferences_service.dart';
import 'connectivity_provider.dart';
import 'firebase_provider.dart';
import 'firestore_provider.dart';
import 'shared_preferences_provider.dart';

final FutureProvider<void> initializationProvider = FutureProvider<void>((Ref ref) async {
  final ConnectivityService connectivityService = ref.read(connectivityServiceProvider);
  final FirebaseService firebaseService = ref.read(firebaseServiceProvider);
  final FirestoreService firestoreService = ref.read(firestoreServiceProvider);
  final SharedPreferencesService sharedPreferencesService = ref.read(
    sharedPreferencesServiceProvider,
  );
  bool isConnected;

  await firebaseService.initialize(DefaultFirebaseOptions.currentPlatform);
  await sharedPreferencesService.initialize();
  isConnected = await connectivityService.isConnected();

  if (!isConnected) {
    firestoreService.instance.disableNetwork();
  }
});
