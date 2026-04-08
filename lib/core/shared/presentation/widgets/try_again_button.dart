import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';

/// A premium, themed button for error recovery.
///
/// Designed to match the aesthetic of other primary actions (like Google Sign-In)
/// but styled for error states.
class TryAgainButton extends ConsumerWidget {
  /// Creates a [TryAgainButton].
  const TryAgainButton({
    required this.onTap,
    super.key,
  });

  /// The callback to execute when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.error,
                  colorScheme.error.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.error.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Try Again',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
