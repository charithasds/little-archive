import 'package:flutter/material.dart';

/// Shared [InputDecoration] builder used by form widgets across the app.
///
/// Provides consistent styling for dropdown fields, input decorators,
/// and any other widget that uses [InputDecoration].
InputDecoration buildFormDecoration(
  ColorScheme colorScheme, {
  String? labelText,
  EdgeInsetsGeometry? contentPadding,
  IconData? prefixIcon,
}) => InputDecoration(
  labelText: labelText,
  prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
  filled: true,
  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
    borderSide: BorderSide(color: colorScheme.error),
  ),
  contentPadding: contentPadding,
);
