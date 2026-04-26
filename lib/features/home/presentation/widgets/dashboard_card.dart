import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';

class DashboardCard extends ConsumerWidget {
  const DashboardCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
    super.key,
  });

  final String title;
  final IconData icon;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;

    return Card(
      color: cs.surfaceContainerHigh,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        splashColor: cs.primary.withValues(alpha: 0.12),
        highlightColor: cs.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: cs.onPrimaryContainer, size: 28),
              ),
              const Spacer(),
              if (count != null)
                Text(
                  count.toString(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.1,
                  ),
                )
              else
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.primary),
                ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
