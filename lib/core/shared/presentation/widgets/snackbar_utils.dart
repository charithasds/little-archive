import 'package:flutter/material.dart';

class SnackBarUtils {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
    );
  }

  static void showError(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
    );
  }

  static void showWarning(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: colorScheme.tertiary,
      foregroundColor: colorScheme.onTertiary,
    );
  }

  static void showInfo(BuildContext context, String message) {
    final ColorScheme colorScheme = _colorScheme(context);
    _showSnackBar(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(icon, color: foregroundColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foregroundColor)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
