import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';

class InfoDialogLoading extends ConsumerWidget {
  const InfoDialogLoading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = ref.watch(activeThemeDataProvider).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CircularProgressIndicator(strokeWidth: 3, color: colorScheme.primary),
      ),
    );
  }
}
