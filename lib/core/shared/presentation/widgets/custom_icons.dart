import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget? buildAppIcon(dynamic icon, {Color? color, double? size}) {
  if (icon == null) {
    return null;
  }
  if (icon is IconData) {
    return Icon(icon, color: color, size: size);
  }
  if (icon is FaIconData) {
    return FaIcon(icon, color: color, size: size);
  }
  return null;
}
