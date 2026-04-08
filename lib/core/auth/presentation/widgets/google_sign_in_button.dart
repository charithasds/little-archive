import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../shared/presentation/utils/snack_bars.dart';
import '../providers/auth_provider.dart';

/// A premium, animated button for Google Sign-In.
///
/// It coordinates with [AuthController] to handle the authentication flow
/// and provides visual feedback during loading states.
class GoogleSignInButton extends ConsumerStatefulWidget {
  /// Creates a [GoogleSignInButton].
  const GoogleSignInButton({super.key});

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  /// Local state to ensure immediate UI feedback before the provider updates.
  bool _isLocalLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final AsyncValue<void> authControllerState = ref.watch(authControllerProvider);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isLoading = authControllerState.isLoading || _isLocalLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : _handleSignIn,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? <Color>[
                          colorScheme.primaryContainer,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ]
                      : <Color>[colorScheme.primary, colorScheme.primary.withValues(alpha: 0.85)],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (isLoading)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 28,
                        height: 28,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.network(
                          'https://developers.google.com/static/identity/images/g-logo.png',
                          errorBuilder: (BuildContext context, Object error, StackTrace? s) => Icon(
                            Icons.g_mobiledata_rounded,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Text(
                      isLoading ? 'Signing in...' : 'Continue with Google',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isDark ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLocalLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      // Check if sign-in resulted in an error from the controller
      final AsyncValue<void> state = ref.read(authControllerProvider);

      if (state.hasError && mounted) {
        final Object error = state.error!;
        if (error is NoConnectionException) {
          SnackBars.showError(context, error.message);
        } else {
          SnackBars.showError(context, 'Sign in failed. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBars.showError(context, 'An unexpected error occurred.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLocalLoading = false);
      }
    }
  }
}
