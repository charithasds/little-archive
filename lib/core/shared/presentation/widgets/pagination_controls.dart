import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            tooltip: 'Previous Page',
            style: IconButton.styleFrom(
              backgroundColor: cs.secondaryContainer.withValues(alpha: 0.5),
              foregroundColor: cs.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Page $currentPage of $totalPages',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton.filledTonal(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            tooltip: 'Next Page',
            style: IconButton.styleFrom(
              backgroundColor: cs.secondaryContainer.withValues(alpha: 0.5),
              foregroundColor: cs.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
