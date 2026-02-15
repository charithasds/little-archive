import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

class InitializationErrorPage extends ConsumerWidget {
  const InitializationErrorPage({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeMode themeMode;
    try {
      themeMode = ref.watch(themeProvider);
    } catch (_) {
      themeMode = ThemeMode.light;
    }

    final ThemeData theme = themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = themeMode == ThemeMode.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? <Color>[
                      const Color(0xFF0d1318),
                      const Color(0xFF121a22),
                      const Color(0xFF1e2d3d),
                    ]
                  : <Color>[
                      const Color(0xFFF8F6F3),
                      const Color(0xFFEDE9E4),
                      colorScheme.primaryContainer,
                    ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildErrorIconSection(colorScheme),

                      const SizedBox(height: 40),

                      _buildErrorTitleSection(theme, colorScheme),

                      const SizedBox(height: 16),

                      Text(
                        'Something went wrong during startup',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      _buildErrorDetailsCard(theme, colorScheme, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIconSection(ColorScheme colorScheme) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOutBack,
    builder: (BuildContext context, double value, Widget? child) =>
        Transform.scale(scale: value, child: child),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.error.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: colorScheme.errorContainer.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[colorScheme.error, colorScheme.error.withValues(alpha: 0.7)],
          ),
        ),
        child: Icon(Icons.error_outline_rounded, size: 80, color: colorScheme.onError),
      ),
    ),
  );

  Widget _buildErrorTitleSection(ThemeData theme, ColorScheme colorScheme) =>
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (BuildContext context, double value, Widget? child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Oops!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (Rect bounds) => LinearGradient(
                colors: <Color>[colorScheme.error, colorScheme.errorContainer],
              ).createShader(bounds),
              child: Text(
                'Initialization Failed',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildErrorDetailsCard(ThemeData theme, ColorScheme colorScheme, bool isDark) =>
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        builder: (BuildContext context, double value, Widget? child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.error.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.bug_report_rounded,
                size: 48,
                color: colorScheme.error.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text(
                'Error Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                ),
                child: SelectableText(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
