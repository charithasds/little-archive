import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';

class DetailSection extends ConsumerWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    this.showDivider = true,
    this.actions,
  });

  final String title;
  final List<Widget> children;
  final bool showDivider;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    if (children.isEmpty && actions == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> displayChildren = children.isEmpty
        ? <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'No volumes added yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ]
        : children;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
        ),
        ...displayChildren,
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
            child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
      ],
    );
  }
}
