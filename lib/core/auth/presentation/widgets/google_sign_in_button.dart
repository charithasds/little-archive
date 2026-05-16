import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../shared/presentation/utils/snack_bars.dart';
import '../providers/auth_provider.dart';

class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool _isLocalLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AsyncValue<void> authControllerState = ref.watch(authControllerProvider);
    final bool isLoading = authControllerState.isLoading || _isLocalLoading;

    return FilledButton(
      onPressed: isLoading ? null : _handleSignIn,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary),
            )
          else
            Container(
              width: 28,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.g_mobiledata_rounded, color: colorScheme.primary, size: 18),
            ),
          const SizedBox(width: 12),
          Text(
            isLoading ? 'Signing in...' : 'Continue with Google',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLocalLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      final AsyncValue<void> state = ref.read(authControllerProvider);

      if (state.hasError && mounted) {
        final Object error = state.error!;
        if (error is NoConnectionException) {
          SnackBars.showError(error.message);
        } else {
          SnackBars.showError('Sign in failed. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBars.showError('An unexpected error occurred.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLocalLoading = false);
      }
    }
  }
}
