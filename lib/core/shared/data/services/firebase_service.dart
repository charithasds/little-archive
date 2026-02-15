import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  Future<FirebaseApp> initialize(FirebaseOptions firebaseOptions) async => Firebase.apps.isEmpty
      ? Firebase.initializeApp(options: firebaseOptions)
      : Firebase.apps.first;
}
