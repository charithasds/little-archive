import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/firebase_service.dart';

final Provider<FirebaseService> firebaseServiceProvider = Provider<FirebaseService>(
  (Ref ref) => FirebaseService(),
);
