import 'package:flutter/material.dart';
import 'custom_icons.dart';

InputDecoration buildFormDecoration(
  ColorScheme colorScheme, {
  String? labelText,
  String? hintText,
  dynamic prefixIcon,
  EdgeInsetsGeometry? contentPadding,
  bool alignLabelWithHint = false,
}) => InputDecoration(
  labelText: labelText,
  hintText: hintText,
  prefixIcon: prefixIcon != null
      ? SizedBox(
          width: 48,
          height: 48,
          child: Center(child: buildAppIcon(prefixIcon, size: 20)),
        )
      : null,
  prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  alignLabelWithHint: alignLabelWithHint,
  filled: true,
  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
  prefixIconColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.error)) {
      return colorScheme.error;
    }
    if (states.contains(WidgetState.focused)) {
      return colorScheme.primary;
    }
    return colorScheme.onSurfaceVariant;
  }),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: colorScheme.primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: colorScheme.error, width: 2),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: colorScheme.error, width: 2),
  ),
  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
  floatingLabelStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.error)) {
      return TextStyle(color: colorScheme.error);
    }
    if (states.contains(WidgetState.focused)) {
      return TextStyle(color: colorScheme.primary);
    }
    return TextStyle(color: colorScheme.onSurfaceVariant);
  }),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  errorStyle: TextStyle(color: colorScheme.error),
  contentPadding: contentPadding,
);
