import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/presentation/widgets/theme_toggle.dart';
import '../widgets/dashboard.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Little Archive'),
      centerTitle: true,
      actions: <Widget>[
        const ThemeToggle(),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Sign Out',
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        ),
      ],
    ),
    body: const Dashboard(),
  );
}
