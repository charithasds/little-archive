import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current user to display their info
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (_, _) => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Little Archive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Hello, ${user?.displayName ?? 'User'}!')],
        ),
      ),
    );
  }
}
