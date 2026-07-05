import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/shared/presentation/providers/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    Phoenix(
      child: ProviderScope(
        overrides: <Object>[
          sharedPreferencesProvider.overrideWithValue(AsyncValue<SharedPreferences>.data(prefs)),
        ].cast(),
        child: const LittleArchiveApp(),
      ),
    ),
  );
}
