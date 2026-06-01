import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import 'custom_icons.dart';

class DetailTile extends ConsumerWidget {
  const DetailTile({
    super.key,
    required this.label,
    required this.value,
    required this.leadingIcon,
    this.onTap,
    this.trailingIcon,
  });

  final String label;
  final String value;
  final dynamic leadingIcon;
  final VoidCallback? onTap;
  final dynamic trailingIcon;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isInteractive = onTap != null;
    final dynamic trailingIconData =
        trailingIcon ?? (onTap != null ? FontAwesomeIcons.chevronRight : null);
    final Color trailingIconColor = trailingIcon != null
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        highlightColor: colorScheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: <Widget>[
              ...<Widget>[
                buildAppIcon(leadingIcon, size: 20, color: colorScheme.onSurfaceVariant)!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isInteractive ? colorScheme.primary : colorScheme.onSurface,
                        fontWeight: isInteractive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingIconData != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: buildAppIcon(trailingIconData, size: 18, color: trailingIconColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
