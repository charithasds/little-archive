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
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
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
    this.trailingIcon,
  });

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onInfo;
  final IconData? trailingIcon;

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
    final ColorScheme cs = theme.colorScheme;

    final bool isInteractive = onTap != null || onInfo != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isInteractive ? (onInfo ?? onTap) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20, color: cs.onSurfaceVariant),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isInteractive ? cs.primary : cs.onSurface,
                        fontWeight: isInteractive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(trailingIcon, size: 18, color: cs.primary),
                )
              else if (onInfo != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
                )
              else if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
