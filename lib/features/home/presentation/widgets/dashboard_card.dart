import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';

enum DashboardCardColor { primary, secondary, tertiary, error, success, blue, purple }

class DashboardCard extends ConsumerStatefulWidget {
  const DashboardCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
    this.subtitle,
    this.countdownTarget,
    this.countdownSuffix,
    this.colorVariant = DashboardCardColor.primary,
    this.showLoader = false,
    super.key,
  });

  final String title;
  final IconData icon;
  final int? count;
  final String? subtitle;
  final DateTime? countdownTarget;
  final String? countdownSuffix;
  final VoidCallback? onTap;
  final DashboardCardColor colorVariant;
  final bool showLoader;

  @override
  ConsumerState<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends ConsumerState<DashboardCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  Timer? _timer;
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String? _tickingLabel;

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

    if (widget.countdownTarget != null) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(DashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.countdownTarget != oldWidget.countdownTarget) {
      _timer?.cancel();
      if (widget.countdownTarget != null) {
        _startTimer();
      } else {
        setState(() {
          _days = 0;
          _hours = 0;
          _minutes = 0;
          _seconds = 0;
          _tickingLabel = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (widget.countdownTarget == null) {
      return;
    }

    final DateTime now = DateTime.now();
    final bool isPast = now.isAfter(widget.countdownTarget!);

    final Duration diff = isPast
        ? now.difference(widget.countdownTarget!)
        : widget.countdownTarget!.difference(now);

    final String label = isPast ? 'AGO' : (widget.countdownSuffix ?? '').trim().toUpperCase();

    setState(() {
      _days = diff.inDays;
      _hours = diff.inHours % 24;
      _minutes = diff.inMinutes % 60;
      _seconds = diff.inSeconds % 60;
      _tickingLabel = label.isNotEmpty ? label : 'COUNTDOWN';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallScreen = screenWidth < 600;

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
        bg = isDark ? const Color(0xFF0F5223) : const Color(0xFFC8E6C9);
        fg = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
        iconTint = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12);
      case DashboardCardColor.blue:
        bg = isDark
            ? const Color(0xFF0D47A1).withValues(alpha: 0.18)
            : const Color(0xFFBBDEFB).withValues(alpha: 0.18);
        fg = isDark ? const Color(0xFF90CAF9) : const Color(0xFF0D47A1);
        iconTint = fg.withValues(alpha: 0.12);
      case DashboardCardColor.purple:
        bg = isDark
            ? const Color(0xFF4A148C).withValues(alpha: 0.18)
            : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
        fg = isDark ? const Color(0xFFE1BEE7) : const Color(0xFF4A148C);
        iconTint = fg.withValues(alpha: 0.12);
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
            padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Icon pill
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                  decoration: BoxDecoration(
                    color: iconTint,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14),
                  ),
                  child: Icon(widget.icon, color: fg, size: isSmallScreen ? 18 : 24),
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
                else if (widget.countdownTarget != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      () {
                        final bool isDark = theme.brightness == Brightness.dark;
                        final bool isCountup = _tickingLabel == 'AGO';

                        final Color segmentBg = isCountup
                            ? (isDark
                                  ? const Color(0xFFC62828).withValues(alpha: 0.2)
                                  : const Color(0xFFFFCDD2).withValues(alpha: 0.5))
                            : (isDark
                                  ? const Color(0xFF1B5E20).withValues(alpha: 0.2)
                                  : const Color(0xFFC8E6C9).withValues(alpha: 0.5));

                        final Color segmentBorder = isCountup
                            ? (isDark
                                  ? const Color(0xFFC62828).withValues(alpha: 0.4)
                                  : const Color(0xFFE57373).withValues(alpha: 0.4))
                            : (isDark
                                  ? const Color(0xFF1B5E20).withValues(alpha: 0.4)
                                  : const Color(0xFF81C784).withValues(alpha: 0.4));

                        final Color segmentText = isCountup
                            ? (isDark ? const Color(0xFFFFEBEE) : const Color(0xFFB71C1C))
                            : (isDark ? const Color(0xFFE8F5E9) : const Color(0xFF1B5E20));

                        final Color labelColor = isCountup
                            ? (isDark ? const Color(0xFFFFEBEE) : const Color(0xFFB71C1C))
                            : (isDark ? const Color(0xFFE8F5E9) : const Color(0xFF1B5E20));

                        final Color badgeBg = isCountup
                            ? (isDark
                                  ? const Color(0xFFC62828).withValues(alpha: 0.3)
                                  : const Color(0xFFFFCDD2).withValues(alpha: 0.7))
                            : (isDark
                                  ? const Color(0xFF1B5E20).withValues(alpha: 0.3)
                                  : const Color(0xFFC8E6C9).withValues(alpha: 0.7));

                        final Widget badge = Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 10,
                            vertical: isSmallScreen ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                          ),
                          child: Text(
                            _tickingLabel ?? 'COUNTDOWN',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: labelColor,
                              letterSpacing: isSmallScreen ? 0.4 : 0.8,
                              fontSize: isSmallScreen ? 8 : 10,
                              height: 1.0,
                            ),
                          ),
                        );

                        final Widget timerRow = Row(
                          children: <Widget>[
                            _buildSegment(
                              context,
                              _days.toString(),
                              'DAYS',
                              segmentBg,
                              segmentBorder,
                              segmentText,
                              theme,
                              isSmallScreen,
                            ),
                            const SizedBox(width: 4),
                            _buildSegment(
                              context,
                              _hours.toString(),
                              'HRS',
                              segmentBg,
                              segmentBorder,
                              segmentText,
                              theme,
                              isSmallScreen,
                            ),
                            const SizedBox(width: 4),
                            _buildSegment(
                              context,
                              _minutes.toString(),
                              'MINS',
                              segmentBg,
                              segmentBorder,
                              segmentText,
                              theme,
                              isSmallScreen,
                            ),
                            const SizedBox(width: 4),
                            _buildSegment(
                              context,
                              _seconds.toString(),
                              'SECS',
                              segmentBg,
                              segmentBorder,
                              segmentText,
                              theme,
                              isSmallScreen,
                            ),
                          ],
                        );

                        final double spacingHeight = isSmallScreen ? 6.0 : 10.0;

                        if (!isCountup) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              badge,
                              SizedBox(height: spacingHeight),
                              timerRow,
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              timerRow,
                              SizedBox(height: spacingHeight),
                              badge,
                            ],
                          );
                        }
                      }(),
                    ],
                  )
                else if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: fg,
                      height: 1.2,
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
                SizedBox(height: isSmallScreen ? 4 : 6),
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

  Widget _buildSegment(
    BuildContext context,
    String value,
    String label,
    Color bg,
    Color border,
    Color text,
    ThemeData theme,
    bool isSmallScreen,
  ) => Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 14),
            border: Border.all(color: border),
          ),
          child: Text(
            value.padLeft(2, '0'),
            style: (isSmallScreen ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(
              fontWeight: FontWeight.w900,
              color: text,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: isSmallScreen ? 8 : 9,
              fontWeight: FontWeight.w800,
              color: text.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    ),
  );
}
