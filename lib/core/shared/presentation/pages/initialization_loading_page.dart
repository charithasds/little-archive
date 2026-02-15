import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

class InitializationLoadingPage extends ConsumerWidget {
  const InitializationLoadingPage({super.key});

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
                      _buildAppIconSection(colorScheme),

                      const SizedBox(height: 40),

                      _buildTitleSection(theme, colorScheme),

                      const SizedBox(height: 16),

                      Text(
                        'Your personal library companion',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      _buildLoadingSection(theme, colorScheme),
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

  Widget _buildAppIconSection(ColorScheme colorScheme) => TweenAnimationBuilder<double>(
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
            color: colorScheme.tertiary.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[colorScheme.tertiary, colorScheme.tertiary.withValues(alpha: 0.7)],
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/icon/app_icon.png',
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );

  Widget _buildTitleSection(ThemeData theme, ColorScheme colorScheme) =>
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
              'Loading',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (Rect bounds) => LinearGradient(
                colors: <Color>[colorScheme.primary, colorScheme.tertiary],
              ).createShader(bounds),
              child: Text(
                'Little Archive',
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

  Widget _buildLoadingSection(ThemeData theme, ColorScheme colorScheme) =>
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        builder: (BuildContext context, double value, Widget? child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                backgroundColor: colorScheme.tertiary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Preparing your library...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
}
