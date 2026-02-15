import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/shared/presentation/pages/initialization_app_page.dart';
import 'core/shared/presentation/pages/initialization_error_page.dart';
import 'core/shared/presentation/pages/initialization_loading_page.dart';
import 'core/shared/presentation/providers/initialization_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> initializationAsync = ref.watch(initializationProvider);

    return initializationAsync.when(
      loading: InitializationLoadingPage.new,
      error: (Object error, _) => InitializationErrorPage(
        error: error,
        onRetry: () => ref.invalidate(initializationProvider),
      ),
      data: (_) => const InitializationAppPage(),
    );
  }
}
