import 'package:flutter/material.dart';

import '../../domain/error/exceptions.dart';
import 'snack_bars.dart';

class AppDialogs {
  AppDialogs._();

  /// Shared M3 Expressive confirmation dialog for destructive actions.
  static Future<bool> showDestructiveDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
  }) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: cs.error, size: 40),
        iconPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Text(title),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
        content: Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Specialized helper for entity deletion logic used across all list pages.
  ///
  /// This handles the confirmation dialog, UseCase execution, and result feedback.
  static Future<void> removeEntity({
    required BuildContext context,
    required String entityType,
    required String entityName,
    required Future<void> Function() onConfirm,
  }) async {
    final bool confirmed = await showDestructiveDialog(
      context,
      title: 'Remove $entityType?',
      content:
          'Are you sure you want to remove $entityType: $entityName? This action cannot be undone.',
      confirmLabel: 'Remove',
    );

    if (!confirmed) {
      return;
    }

    try {
      await onConfirm();
      SnackBars.showSuccess('$entityType removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }
}
