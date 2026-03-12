import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';
import 'form_decoration.dart';

class MultiSelectField<T> extends ConsumerWidget {
  const MultiSelectField({
    super.key,
    required this.selectedItems,
    required this.allItems,
    required this.itemLabel,
    required this.onChanged,
    required this.label,
    this.onAdd,
    this.itemKey,
  });

  final List<T> selectedItems;
  final List<T> allItems;
  final String Function(T) itemLabel;
  final void Function(List<T>) onChanged;
  final String label;
  final VoidCallback? onAdd;
  final Object Function(T)? itemKey;

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

    final List<T> syncedSelectedItems = <T>[];
    for (final T selected in selectedItems) {
      final Iterable<T> match = allItems.where((T item) => _areEqual(item, selected));
      if (match.isNotEmpty) {
        syncedSelectedItems.add(match.first);
      } else {
        syncedSelectedItems.add(selected);
      }
    }

    final List<T> availableItems = allItems
        .where((T item) => !syncedSelectedItems.any((T s) => _areEqual(s, item)))
        .toList();

    final String itemsKey = availableItems.map((T i) => i.hashCode).join(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: buildFormDecoration(colorScheme, contentPadding: const EdgeInsets.all(8)),
          child: Wrap(
            spacing: 8.0,
            children: <Widget>[
              if (syncedSelectedItems.isEmpty)
                Text(
                  'No items selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ...syncedSelectedItems.map(
                (T item) => Chip(
                  label: Text(itemLabel(item)),
                  onDeleted: () {
                    final List<T> newList = List<T>.from(syncedSelectedItems)..remove(item);
                    onChanged(newList);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: DropdownButtonFormField<T>(
                key: ValueKey<String>('dropdown_$itemsKey'),
                decoration: buildFormDecoration(
                  colorScheme,
                  labelText: 'Add $label',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                items: availableItems.isEmpty
                    ? <DropdownMenuItem<T>>[]
                    : availableItems
                          .map(
                            (T item) => DropdownMenuItem<T>(
                              value: item,
                              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                onChanged: (T? value) {
                  if (value != null) {
                    final List<T> newList = List<T>.from(syncedSelectedItems)..add(value);
                    onChanged(newList);
                  }
                },
              ),
            ),
            if (onAdd != null) ...<Widget>[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAdd,
                tooltip: 'Create new $label',
              ),
            ],
          ],
        ),
      ],
    );
  }
}
