import 'package:flutter/material.dart';

class SnackBars {
  SnackBars._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
    );
  }

  static void showError(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
    );
  }

  static void showWarning(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: colorScheme.tertiaryContainer,
      foregroundColor: colorScheme.onTertiaryContainer,
    );
  }

  static void showInfo(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    );
  }

  static ColorScheme _colorScheme(BuildContext context) => Theme.of(context).colorScheme;

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    if (!context.mounted) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
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
