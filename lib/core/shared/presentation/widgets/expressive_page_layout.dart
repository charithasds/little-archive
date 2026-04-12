import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';

const double _kCompactBreakpoint = 600.0;
const double _kMediumBreakpoint = 1200.0;

const double _kContentMaxWidth = 440.0;

const double _kVerticalPadding = 48.0;

class _SizeTokens {
  const _SizeTokens({
    required this.iconHeight,
    required this.iconBottomSpacing,
    required this.titleStyle,
    required this.descriptionStyle,
  });

  final double iconHeight;
  final double iconBottomSpacing;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
}

class ExpressivePageLayout extends ConsumerWidget {
  const ExpressivePageLayout({
    required this.title,
    required this.description,
    required this.content,
    this.secondaryContent,
    this.useErrorColors = false,
    super.key,
  });

  final String title;
  final String description;
  final Widget content;
  final Widget? secondaryContent;
  final bool useErrorColors;

  _SizeTokens _sizeTokens(double screenWidth, TextTheme textTheme) {
    if (screenWidth < _kCompactBreakpoint) {
      return _SizeTokens(
        iconHeight: 140,
        iconBottomSpacing: 24,
        titleStyle: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        descriptionStyle: textTheme.bodyMedium?.copyWith(height: 1.5),
      );
    } else if (screenWidth < _kMediumBreakpoint) {
      return _SizeTokens(
        iconHeight: 180,
        iconBottomSpacing: 32,
        titleStyle: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        descriptionStyle: textTheme.bodyLarge?.copyWith(height: 1.5),
      );
    } else {
      return _SizeTokens(
        iconHeight: 220,
        iconBottomSpacing: 40,
        titleStyle: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
        descriptionStyle: textTheme.bodyLarge?.copyWith(height: 1.5),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final Color descriptionColor = useErrorColors
        ? colorScheme.error
        : colorScheme.onSurface.withValues(alpha: 0.6);

    final _SizeTokens tokens = _sizeTokens(screenWidth, theme.textTheme);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: _kVerticalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - _kVerticalPadding * 2)
                        .clamp(0.0, double.infinity),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Spacer(flex: 3),

                        Image.asset(
                          'assets/icon/app_icon.png',
                          height: tokens.iconHeight,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: tokens.iconBottomSpacing),

                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: tokens.titleStyle?.copyWith(color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: tokens.descriptionStyle?.copyWith(color: descriptionColor),
                        ),

                        const Spacer(flex: 2),

                        content,

                        if (secondaryContent != null) ...<Widget>[
                          const SizedBox(height: 16),
                          secondaryContent!,
                        ],

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
