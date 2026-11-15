import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageUtils {
  ImageUtils._();

  static String? compressImageIfNeeded(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return base64Image;
    }

    const int threshold = 50000;

    if (base64Image.length < threshold) {
      return base64Image;
    }

    try {
      final Uint8List bytes = base64Decode(base64Image);
      img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return base64Image;
      }

      if (decodedImage.width <= 400 && decodedImage.height <= 400) {
        return base64Image;
      }

      decodedImage = img.copyResize(
        decodedImage,
        width: decodedImage.width > decodedImage.height ? 400 : null,
        height: decodedImage.height >= decodedImage.width ? 400 : null,
        interpolation: img.Interpolation.average,
      );

      final Uint8List compressed = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 70));
      return base64Encode(compressed);
    } catch (e) {
      return base64Image;
    }
  }
}
