import 'package:flutter/material.dart';

class Buttons {
  Buttons._();

  static Color getPrimaryActionBackgroundColor(ThemeData theme) => theme.colorScheme.primary;

  static Color getPrimaryActionForegroundColor(ThemeData theme) => theme.colorScheme.onPrimary;

  static ButtonStyle getPrimaryFilledButtonStyle(ThemeData theme) => FilledButton.styleFrom(
    backgroundColor: getPrimaryActionBackgroundColor(theme),
    foregroundColor: getPrimaryActionForegroundColor(theme),
    disabledBackgroundColor: getPrimaryActionBackgroundColor(theme),
    disabledForegroundColor: getPrimaryActionForegroundColor(theme),
    minimumSize: const Size.fromHeight(56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}
