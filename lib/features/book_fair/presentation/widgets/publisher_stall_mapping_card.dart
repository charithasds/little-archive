import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';

class PublisherStallMappingCard extends ConsumerWidget {
  const PublisherStallMappingCard({
    required this.publisher,
    required this.selectedStallId,
    required this.selectedStall,
    required this.onTapStall,
    super.key,
  });

  final PublisherEntity publisher;
  final String? selectedStallId;
  final BookFairStallEntity? selectedStall;
  final VoidCallback onTapStall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color purpleContainer = isDark
        ? const Color(0xFF4A148C).withValues(alpha: 0.18)
        : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);
    final Widget publisherCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          publisher.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (publisher.otherName != null && publisher.otherName!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              publisher.otherName!,
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
    final Widget stallCol = InkWell(
      onTap: onTapStall,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedStall != null
              ? purpleContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border.all(
            color: selectedStall != null
                ? purplePrimary.withValues(alpha: 0.35)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selectedStall != null ? Icons.storefront_rounded : Icons.storefront_outlined,
              color: selectedStall != null ? purplePrimary : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: selectedStall != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          selectedStall!.name,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hall ${selectedStall!.halls.join(', ')} • Stall ${selectedStall!.stallNo}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'None Selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_rounded, size: 16, color: purplePrimary),
          ],
        ),
      ),
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selectedStallId != null && selectedStallId != 'none'
              ? purplePrimary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isCompact = constraints.maxWidth < 650;
            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[publisherCol, const SizedBox(height: 12), stallCol],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(flex: 4, child: publisherCol),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: stallCol),
              ],
            );
          },
        ),
      ),
    );
  }
}
