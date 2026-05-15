import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';

enum DashboardCardColor { primary, secondary, tertiary, error, success }

class DashboardCard extends ConsumerStatefulWidget {
  const DashboardCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
    this.colorVariant = DashboardCardColor.primary,
    this.showLoader = false,
    super.key,
  });

  final String title;
  final IconData icon;
  final int? count;
  final VoidCallback? onTap;
  final DashboardCardColor colorVariant;
  final bool showLoader;

  @override
  ConsumerState<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends ConsumerState<DashboardCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;

    final Color bg;
    final Color fg;
    final Color iconTint;

    switch (widget.colorVariant) {
      case DashboardCardColor.primary:
        bg = cs.primaryContainer;
        fg = cs.onPrimaryContainer;
        iconTint = cs.primary.withValues(alpha: 0.12);
      case DashboardCardColor.secondary:
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
        iconTint = cs.secondary.withValues(alpha: 0.12);
      case DashboardCardColor.tertiary:
        bg = cs.tertiaryContainer;
        fg = cs.onTertiaryContainer;
        iconTint = cs.tertiary.withValues(alpha: 0.12);
      case DashboardCardColor.error:
        bg = cs.errorContainer;
        fg = cs.onErrorContainer;
        iconTint = cs.error.withValues(alpha: 0.12);
      case DashboardCardColor.success:
        final bool isDark = theme.brightness == Brightness.dark;
        bg = isDark ? const Color(0xFF0F5223) : const Color(0xFFC8E6C9);
        fg = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
        iconTint = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12);
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Card(
          color: bg,
          elevation: 0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Icon pill
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: fg, size: 24),
                ),
                const Spacer(),
                // Count (only shown when not null)
                if (widget.count != null)
                  Text(
                    widget.count.toString(),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: fg,
                      height: 1.0,
                    ),
                  )
                else if (widget.showLoader)
                  SizedBox(
                    height: 40, // Height of the displaySmall text
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(fg.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 6),
                // Title
                Text(
                  widget.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg.withValues(alpha: 0.85),
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
      ),
    );
  }
}
