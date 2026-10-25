import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/images.dart';

/// Fullscreen image viewer page supporting pinch-to-zoom and pan.
/// Opened when tapping a book cover, publisher logo, creator picture, or reader picture.
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({
    super.key,
    required this.imageSource,
    this.title,
    this.heroTag,
  });

  final String imageSource;
  final String? title;
  final String? heroTag;

  static Future<void> open(
    BuildContext context, {
    required String imageSource,
    String? title,
    String? heroTag,
  }) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext ctx) => ImageViewerPage(
            imageSource: imageSource,
            title: title,
            heroTag: heroTag,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image(
      image: Images.getImageProvider(imageSource),
      fit: BoxFit.contain,
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: title != null && title!.isNotEmpty
            ? Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          clipBehavior: Clip.none,
          child: imageWidget,
        ),
      ),
    );
  }
}
