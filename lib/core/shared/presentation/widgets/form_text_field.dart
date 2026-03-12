import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

/// A reusable text form field that matches the app's design system.
///
/// Configurable for various field types (name, email, phone, url, notes, etc.)
/// via parameters. Handles capitalization, keyboard type, validation, and
/// consistent styling automatically.
class FormTextField extends ConsumerWidget {
  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.isRequired = false,
    this.alignLabelWithHint = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final bool alignLabelWithHint;
  final bool autofocus;

  /// Determines the appropriate [TextCapitalization] for this field.
  ///
  /// If explicitly set via [textCapitalization], uses that value.
  /// Otherwise, multi-line fields (notes) use [TextCapitalization.sentences],
  /// URL/email/phone fields use [TextCapitalization.none],
  /// and all other fields capitalize each word.
  TextCapitalization get _effectiveCapitalization {
    if (textCapitalization != null) {
      return textCapitalization!;
    }

    if (maxLines > 1) {
      return TextCapitalization.sentences;
    }

    if (keyboardType == TextInputType.url ||
        keyboardType == TextInputType.emailAddress ||
        keyboardType == TextInputType.phone) {
      return TextCapitalization.none;
    }

    return TextCapitalization.words;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeProvider);
    final ThemeData theme = themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        alignLabelWithHint: alignLabelWithHint || maxLines > 1,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
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
      ),
      keyboardType: keyboardType,
      textCapitalization: _effectiveCapitalization,
      validator:
          validator ??
          (isRequired ? (String? v) => v!.trim().isEmpty ? '$label is required' : null : null),
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
    );
  }
}
