import 'package:flutter/material.dart';

/// A utility class for displaying standardized [SnackBar] notifications.
///
/// Use this class to provide quick, non-intrusive feedback to the user
/// about the result of an operation.
class SnackBars {
  SnackBars._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Displays a success notification with a check icon.
  /// Typically used for successful saves, updates, or deletes.
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

  /// Displays an error notification with an error icon.
  /// Typically used for unexpected failures or validation errors.
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

  /// Displays a warning notification with a warning icon.
  /// Typically used for actions that might have side effects or require caution.
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

  /// Displays an informational notification with an info icon.
  /// Typically used for neutral status updates.
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
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
