import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import '../providers/initialization_provider.dart';
import '../widgets/expressive_page_layout.dart';
import '../widgets/try_again_button.dart';

class ErrorPage extends ConsumerWidget {
  const ErrorPage({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return ExpressivePageLayout(
      title: 'Little Archive',
      description: 'Something went wrong',
      useErrorColors: true,
      content: TryAgainButton(onTap: onRetry ?? () => ref.invalidate(initializationProvider)),
      secondaryContent: Text(
        error.toString(),
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.error.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
