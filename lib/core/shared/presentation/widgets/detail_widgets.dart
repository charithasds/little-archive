import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    this.showDivider = true,
  });

  final String title;
  final List<Widget> children;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), thickness: 1),
          ),
      ],
    );
  }
}

class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
    this.onInfo,
  });

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onInfo;

  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('MMM d, yyyy, HH:mm:ss');
    final String formattedDate = formatter.format(date);

    final Duration offset = date.timeZoneOffset;
    final String sign = offset.isNegative ? '-' : '+';
    final String hours = offset.inHours.abs().toString().padLeft(2, '0');
    final String minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    return '$formattedDate ($sign$hours:$minutes)';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onInfo ?? onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onInfo != null)
              Icon(Icons.info_outline_rounded, size: 20, color: colorScheme.primary)
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
