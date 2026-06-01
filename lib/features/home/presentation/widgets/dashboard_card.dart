import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/widgets/custom_icons.dart';
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
  final dynamic icon;
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
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isSmallScreen = screenSize.width < 600;

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

    final double iconPad = isSmallScreen ? 8 : 12;
    final double iconSize = isSmallScreen ? 20 : 26;
    final double iconRadius = isSmallScreen ? 12 : 16;

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
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : 16,
              vertical: isSmallScreen ? 14 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ── Icon pill — top-left ─────────────────────────────────
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(iconPad),
                    decoration: BoxDecoration(
                      color: iconTint,
                      borderRadius: BorderRadius.circular(iconRadius),
                    ),
                    child: buildAppIcon(widget.icon, color: fg, size: iconSize),
                  ),
                ),

                // ── Count — center, center ────────────────────────────────
                // Note: no Center wrapper — Expanded gives tight constraints so FittedBox can scale UP
                Expanded(child: _buildCenterContent(theme, fg, isSmallScreen)),

                // ── Title — larger, bottom-center ─────────────────────────
                Text(
                  widget.title,
                  style: (isSmallScreen ? theme.textTheme.bodyLarge : theme.textTheme.titleMedium)
                      ?.copyWith(
                        color: fg.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterContent(ThemeData theme, Color fg, bool isSmallScreen) {
    if (widget.count != null) {
      // Expanded (caller) provides tight constraints → FittedBox.contain scales text to fill the space
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: FittedBox(
          child: Text(
            widget.count.toString(),
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: fg,
              height: 1.0,
            ),
          ),
        ),
      );
    }

    if (widget.countdownTarget != null) {
      final bool isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
      return Center(child: _buildCountdownContent(theme, fg, isSmallScreen, isLandscape));
    }

    if (widget.subtitle != null) {
      return Text(
        widget.subtitle!,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: fg,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (widget.showLoader) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(fg.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCountdownContent(ThemeData theme, Color fg, bool isSmallScreen, bool isLandscape) {
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
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 3 : 4,
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
          letterSpacing: isSmallScreen ? 0.6 : 0.8,
          fontSize: isSmallScreen ? 11 : 10,
          height: 1.0,
        ),
      ),
    );

    final Widget timerRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
          isLandscape: isLandscape,
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
          isLandscape: isLandscape,
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
          isLandscape: isLandscape,
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
          isLandscape: isLandscape,
        ),
      ],
    );

    final double spacingHeight = isSmallScreen ? 12.0 : 10.0;

    if (!isCountup) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          badge,
          SizedBox(height: spacingHeight),
          timerRow,
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          timerRow,
          SizedBox(height: spacingHeight),
          badge,
        ],
      );
    }
  }

  Widget _buildSegment(
    BuildContext context,
    String value,
    String label,
    Color bg,
    Color border,
    Color text,
    ThemeData theme,
    bool isSmallScreen, {
    bool isLandscape = false,
  }) => Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          // In landscape the card is shorter — use tighter vertical padding
          padding: EdgeInsets.symmetric(vertical: isLandscape ? 2 : (isSmallScreen ? 3 : 6)),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 14),
            border: Border.all(color: border),
          ),
          child: Text(
            value.padLeft(2, '0'),
            // Use titleSmall in landscape to save vertical space
            style:
                (isLandscape || isSmallScreen
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.titleMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: text,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
          ),
        ),
        const SizedBox(height: 2),
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
