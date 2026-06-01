import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import '../utils/images.dart';
import 'custom_icons.dart';

class InfoDialogCircleImage extends ConsumerWidget {
  const InfoDialogCircleImage({this.image, required this.icon, super.key});

  final String? image;
  final dynamic icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
