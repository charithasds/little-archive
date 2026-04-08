import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? <Color>[
                    theme.scaffoldBackgroundColor,
                    colorScheme.surface,
                    colorScheme.primary.withValues(alpha: 0.05),
                  ]
                : <Color>[
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest,
                    colorScheme.primaryContainer.withValues(alpha: 0.3),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 3),

                // App Branding Section
                Image.asset('assets/icon/app_icon.png', height: 220, fit: BoxFit.contain),
                const SizedBox(height: 32),
                Text(
                  'Little Archive',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your personal library companion',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),

                const Spacer(flex: 2),

                // Authentication Section
                const GoogleSignInButton(),
                const SizedBox(height: 24),
                Text(
                  'Keep your library in sync across all your devices.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
