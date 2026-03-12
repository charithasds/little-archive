import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import 'form_decoration.dart';

class SingleSelectField<T> extends ConsumerWidget {
  const SingleSelectField({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.label,
    this.onAdd,
    this.itemKey,
    this.isNullable = true,
  });

  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String label;
  final VoidCallback? onAdd;
  final Object Function(T)? itemKey;
  final bool isNullable;

  bool _areEqual(T a, T b) {
    if (itemKey != null) {
      return itemKey!(a) == itemKey!(b);
    }
    return a == b;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeProvider);
    final ThemeData theme = themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    final List<T> effectiveItems = <T>[...items];
    if (value != null && !effectiveItems.any((T e) => _areEqual(e, value as T))) {
      effectiveItems.add(value as T);
    }

    final T? effectiveValue = value != null
        ? effectiveItems.where((T e) => _areEqual(e, value as T)).firstOrNull
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<T>(
            key: ValueKey<String>(effectiveItems.map((T i) => i.hashCode).join(',')),
            decoration: buildFormDecoration(colorScheme, labelText: label),
            items: <DropdownMenuItem<T>>[
              if (isNullable) DropdownMenuItem<T>(child: const Text('None')),
              ...effectiveItems.map(
                (T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            initialValue: effectiveValue,
            onChanged: onChanged,
            validator: (T? val) {
              if (!isNullable && val == null) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
        if (onAdd != null) ...<Widget>[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
            tooltip: 'Add new $label',
          ),
        ],
      ],
    );
  }
}
