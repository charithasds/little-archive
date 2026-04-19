import 'package:flutter/material.dart';

class SnackBars {
  SnackBars._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message, {BuildContext? context}) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
    );
  }

  static void showError(String message, {BuildContext? context}) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
    );
  }

  static void showWarning(String message, {BuildContext? context}) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: colorScheme.tertiaryContainer,
      foregroundColor: colorScheme.onTertiaryContainer,
    );
  }

  static void showInfo(String message, {BuildContext? context}) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    );
  }

  static ColorScheme _colorScheme(BuildContext? context) {
    final BuildContext? effectiveContext = messengerKey.currentContext ??
        (context != null && context.mounted ? context : null);

    if (effectiveContext == null) {
      return const ColorScheme.light();
    }
    return Theme.of(effectiveContext).colorScheme;
  }

  static void _showSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final ScaffoldMessengerState? messenger = messengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(icon, color: foregroundColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: foregroundColor.withOpacity(0.1)),
        ),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      ),
    );
  }
}
