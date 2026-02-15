import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

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
            decoration: _buildInputDecoration(colorScheme, labelText: label),
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
          decoration: _buildInputDecoration(colorScheme, contentPadding: const EdgeInsets.all(8)),
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
                decoration: _buildInputDecoration(
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

InputDecoration _buildInputDecoration(
  ColorScheme colorScheme, {
  String? labelText,
  EdgeInsetsGeometry? contentPadding,
}) => InputDecoration(
  labelText: labelText,
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
