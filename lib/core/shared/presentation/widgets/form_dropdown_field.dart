import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import 'form_decoration.dart';

class FormDropdownField<T> extends ConsumerWidget {
  const FormDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.prefixIcon,
    this.isNullable = true,
  });

  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final IconData? prefixIcon;
  final bool isNullable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return DropdownButtonFormField<T>(
      value: value,
      items: <DropdownMenuItem<T>>[
        if (isNullable) DropdownMenuItem<T>(child: const Text('None')),
        ...items.map((T item) => DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)))),
      ],
      onChanged: onChanged,
      decoration: buildFormDecoration(colorScheme, labelText: label, prefixIcon: prefixIcon),
      icon: Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurfaceVariant),
      dropdownColor: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
    );
  }
}
