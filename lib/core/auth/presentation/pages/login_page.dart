import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeProvider);
    final ThemeData theme = themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? <Color>[const Color(0xFF0d1318), const Color(0xFF121a22), const Color(0xFF1e2d3d)]
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

                    _buildSignInSection(theme, colorScheme, isDark),
                  ],
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
              'Welcome to',
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

  Widget _buildSignInSection(ThemeData theme, ColorScheme colorScheme, bool isDark) =>
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
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Icon(Icons.menu_book_rounded, size: 48, color: colorScheme.tertiary),
              const SizedBox(height: 16),
              Text(
                'Get Started',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access your library',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              const GoogleSignInButton(),
            ],
          ),
        ),
      );
}
