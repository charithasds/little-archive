import 'package:flutter/material.dart';

/// M3 Expressive empty-state for list pages.
///
/// Uses the same card + icon-container treatment as [DashboardCard] to
/// maintain visual consistency across the app.
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 52, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// M3 Expressive loading state for list pages.
///
/// Centres a [CircularProgressIndicator] coloured with the theme's primary.
class ListLoadingState extends StatelessWidget {
  const ListLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary));
  }
}

/// M3 Expressive error state for list pages.
///
/// Mirrors [ListEmptyState]'s layout but uses error-colour tokens.
class ListErrorState extends StatelessWidget {
  const ListErrorState({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.error_outline_rounded, size: 52, color: cs.onErrorContainer),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
