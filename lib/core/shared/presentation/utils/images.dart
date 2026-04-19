import 'dart:convert';
import 'package:flutter/material.dart';

class Images {
  Images._();

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

  static ImageProvider getImageProvider(
    String? imageSource, {
    String fallbackAsset = 'assets/icon/app_icon.png',
  }) {
    if (imageSource == null || imageSource.isEmpty) {
      return AssetImage(fallbackAsset);
    }

    if (imageSource.startsWith('http')) {
      return NetworkImage(imageSource);
    } else {
      try {
        return MemoryImage(base64Decode(imageSource));
      } catch (e) {
        return AssetImage(fallbackAsset);
      }
    }
  }

  static Widget getImage(
    String? imageSource, {
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    String fallbackAsset = 'assets/icon/app_icon.png',
    double? width,
    double? height,
  }) =>
      Image(
        image: getImageProvider(imageSource, fallbackAsset: fallbackAsset),
        fit: fit,
        width: width,
        height: height,
        errorBuilder:
            errorBuilder ??
            (BuildContext context, Object error, StackTrace? stackTrace) =>
                Image.asset(fallbackAsset, fit: fit, width: width, height: height),
      );
}
