import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import 'form_decoration.dart';

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
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      decoration: buildFormDecoration(
        colorScheme,
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        alignLabelWithHint: alignLabelWithHint || maxLines > 1,
      ),
      keyboardType: keyboardType,
      textCapitalization: _effectiveCapitalization,
      validator:
          validator ??
          (isRequired ? (String? v) => v!.trim().isEmpty ? '$label is required' : null : null),
      maxLength: maxLength,
      buildCounter: maxLength == null
          ? null
          : (
              BuildContext context, {
              required int currentLength,
              required int? maxLength,
              required bool isFocused,
            }) {
              if (currentLength < (maxLength! * 0.95)) {
                return null;
              }
              return Text('$currentLength / $maxLength', style: theme.textTheme.bodySmall);
            },
      maxLines: maxLines,
      inputFormatters: inputFormatters,
    );
  }
}
