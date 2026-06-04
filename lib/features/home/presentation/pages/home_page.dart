import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../widgets/dashboard.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Little Archive'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.primary,
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Dashboard(),
    );
  }
}
