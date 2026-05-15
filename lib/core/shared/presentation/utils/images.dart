import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

enum ImageShape { circle, square, rectangle }

class Images {
  Images._();

  static const double bookAspectRatio = 3 / 4;

  static BoxDecoration getPickerDecoration(
    ThemeData theme, {
    DecorationImage? image,
    ImageShape shape = ImageShape.circle,
  }) {
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasImage = image != null;

    return BoxDecoration(
      shape: shape == ImageShape.circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: shape == ImageShape.circle ? null : BorderRadius.circular(24),
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
    BoxFit fit = BoxFit.contain,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    String fallbackAsset = 'assets/icon/app_icon.png',
    double? width,
    double? height,
  }) => Image(
    image: getImageProvider(imageSource, fallbackAsset: fallbackAsset),
    fit: fit,
    width: width,
    height: height,
    errorBuilder:
        errorBuilder ??
        (BuildContext context, Object error, StackTrace? stackTrace) =>
            Image.asset(fallbackAsset, fit: fit, width: width, height: height),
  );

  static String? ensureFitsFirestore(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return base64Image;
    }

    const int threshold = 800000;

    if (base64Image.length < threshold) {
      return base64Image;
    }

    try {
      final Uint8List bytes = base64Decode(base64Image);
      img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return base64Image;
      }

      Uint8List compressed = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 90));
      String encoded = base64Encode(compressed);

      if (encoded.length < threshold) {
        return encoded;
      }

      if (decodedImage.width > 1024 || decodedImage.height > 1024) {
        decodedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > decodedImage.height ? 1024 : null,
          height: decodedImage.height >= decodedImage.width ? 1024 : null,
          interpolation: img.Interpolation.average,
        );
      }
      compressed = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 80));
      encoded = base64Encode(compressed);

      if (encoded.length < threshold) {
        return encoded;
      }

      decodedImage = img.copyResize(
        decodedImage,
        width: decodedImage.width > decodedImage.height ? 600 : null,
        height: decodedImage.height >= decodedImage.width ? 600 : null,
        interpolation: img.Interpolation.average,
      );
      compressed = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 70));
      encoded = base64Encode(compressed);

      return encoded;
    } catch (e) {
      return base64Image;
    }
  }
}
