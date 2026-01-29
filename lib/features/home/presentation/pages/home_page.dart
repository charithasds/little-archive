import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/presentation/widgets/theme_toggle.dart';
import 'dashboard_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 28,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            const Text('Little Archive'),
          ],
        ),
        centerTitle: false,
        actions: [
          const ThemeToggle(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: const DashboardPage(),
    );
  }
}
