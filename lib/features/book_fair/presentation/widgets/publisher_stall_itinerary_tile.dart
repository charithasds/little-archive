import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';

class PublisherStallItineraryTile extends ConsumerWidget {
  const PublisherStallItineraryTile({
    required this.publisher,
    required this.stall,
    required this.isVisited,
    required this.onTap,
    this.borderRadius,
    super.key,
  });

  final PublisherEntity publisher;
  final BookFairStallEntity stall;
  final bool isVisited;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color purpleContainer = isDark
        ? const Color(0xFF4A148C).withValues(alpha: 0.18)
        : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
    final Color onPurpleContainer = isDark ? const Color(0xFFE1BEE7) : const Color(0xFF4A148C);
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isVisited ? purplePrimary : colorScheme.outline,
                  width: isVisited ? 12 : 2,
                ),
              ),
              child: isVisited
                  ? const Center(child: Icon(Icons.check, size: 14, color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    stall.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isVisited ? TextDecoration.lineThrough : null,
                      color: isVisited
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    publisher.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isVisited
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                          : colorScheme.onSurfaceVariant,
                      decoration: isVisited ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isVisited
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                    : purpleContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                stall.stallNo,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isVisited
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : onPurpleContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
