import 'package:flutter/material.dart';

class ImageStyles {
  ImageStyles._();

  static BoxDecoration getPickerDecoration(ThemeData theme, {DecorationImage? image}) {
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasImage = image != null;

    return BoxDecoration(
      shape: BoxShape.circle,
      color: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
          : colorScheme.primaryContainer.withValues(alpha: 0.3),
      border: Border.all(
        color: colorScheme.primary.withValues(alpha: hasImage ? 1.0 : 0.5),
        width: 3,
      ),
      image: image,
    );
  }

  static Color getPickerIconColor(ThemeData theme) => theme.colorScheme.primary;

  static Color getAvatarBackgroundColor(ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;
    return theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : colorScheme.primaryContainer.withValues(alpha: 0.3);
  }

  static Color getAvatarIconColor(ThemeData theme) => theme.colorScheme.primary;
}
