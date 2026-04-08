import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import '../providers/initialization_provider.dart';
import '../widgets/try_again_button.dart';

class ErrorPage extends ConsumerWidget {
  const ErrorPage({
    required this.error,
    this.onRetry,
    super.key,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? <Color>[
                    theme.scaffoldBackgroundColor,
                    colorScheme.surface,
                    colorScheme.primary.withValues(alpha: 0.05),
                  ]
                : <Color>[
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest,
                    colorScheme.primaryContainer.withValues(alpha: 0.3),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 3),

                // App Branding Section (Error State)
                Image.asset(
                  'assets/icon/app_icon.png',
                  height: 220,
                  fit: BoxFit.contain,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 32),
                Text(
                  'Little Archive',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),

                const Spacer(flex: 2),

                // Error Action Section
                TryAgainButton(
                  onTap: onRetry ?? () => ref.invalidate(initializationProvider),
                ),
                const SizedBox(height: 24),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.error.withValues(alpha: 0.7),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
