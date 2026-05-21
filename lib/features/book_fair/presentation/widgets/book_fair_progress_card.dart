import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';

class BookFairProgressCard extends ConsumerWidget {
  const BookFairProgressCard({
    required this.visitedCount,
    required this.totalStalls,
    required this.progress,
    super.key,
  });

  final int visitedCount;
  final int totalStalls;
  final double progress;

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
    final Color onPurplePrimary = isDark ? const Color(0xFF311B92) : Colors.white;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            purpleContainer,
            purplePrimary.withValues(alpha: isDark ? 0.12 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: purplePrimary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Your Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onPurpleContainer,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: purplePrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$visitedCount of $totalStalls Stalls',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: onPurplePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(purplePrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0
                ? '🎉 Amazing! You have visited all mapped stalls!'
                : 'Follow the Hall-by-Hall route to optimize your book fair visit.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onPurpleContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
