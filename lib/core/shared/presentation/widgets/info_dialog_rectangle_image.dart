import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import '../utils/images.dart';
import 'custom_icons.dart';

class InfoDialogImageRectangle extends ConsumerWidget {
  const InfoDialogImageRectangle({this.image, required this.icon, super.key});

  final String? image;
  final dynamic icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return Container(
      width: 140,
      height: 140 / Images.bookAspectRatio,
      decoration: BoxDecoration(
        color: Images.getAvatarBackgroundColor(theme),
        image: image != null && image!.isNotEmpty
            ? DecorationImage(image: Images.getImageProvider(image), fit: BoxFit.contain)
            : null,
      ),
      child: image == null || image!.isEmpty
          ? buildAppIcon(icon, color: Images.getAvatarIconColor(theme), size: 60)!
          : null,
    );
  }
}
