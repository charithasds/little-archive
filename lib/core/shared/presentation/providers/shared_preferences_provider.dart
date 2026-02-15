import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/shared_preferences_service.dart';

final Provider<SharedPreferencesService> sharedPreferencesServiceProvider =
    Provider<SharedPreferencesService>((Ref ref) => SharedPreferencesService());
