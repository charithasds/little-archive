import 'package:flutter/material.dart';

class SingleSelectField<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Ensure the current value is included in the items list to avoid DropdownButton assertion error
    final List<T> effectiveItems = <T>[...items];
    if (value != null && !effectiveItems.any((T e) => _areEqual(e, value as T))) {
      effectiveItems.add(value as T);
    }

    // Find the matching item from the effective items list
    final T? effectiveValue = value != null
        ? effectiveItems.where((T e) => _areEqual(e, value as T)).firstOrNull
        : null;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<T>(
            // Use a key based on items to force rebuild when list changes
            key: ValueKey<String>(effectiveItems.map((T i) => i.hashCode).join(',')),
            decoration: InputDecoration(
              labelText: label,
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
                borderSide: BorderSide(color: colorScheme.error),
              ),
            ),
            items: <DropdownMenuItem<T>>[
              if (isNullable) DropdownMenuItem<T>(child: const Text('None')),
              ...effectiveItems.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                );
              }),
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

class MultiSelectField<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Determine displayed chips.
    // If a selected item is in allItems, use that reference.
    // If not (e.g. newly created), use the selected item itself.
    final List<T> syncedSelectedItems = <T>[];
    for (final T selected in selectedItems) {
      final Iterable<T> match = allItems.where((T item) => _areEqual(item, selected));
      if (match.isNotEmpty) {
        syncedSelectedItems.add(match.first);
      } else {
        syncedSelectedItems.add(selected);
      }
    }

    // Filter out already selected items for the dropdown
    final List<T> availableItems = allItems
        .where((T item) => !syncedSelectedItems.any((T s) => _areEqual(s, item)))
        .toList();

    // Generate a key based on availableItems to force rebuild when selection changes
    final String itemsKey = availableItems.map((T i) => i.hashCode).join(',');

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
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
              borderSide: BorderSide(color: colorScheme.error),
            ),
            contentPadding: const EdgeInsets.all(8),
          ),
          child: Wrap(
            spacing: 8.0,
            children: <Widget>[
              if (syncedSelectedItems.isEmpty)
                const Text('No items selected', style: TextStyle(color: Colors.grey)),
              ...syncedSelectedItems.map((T item) {
                return Chip(
                  label: Text(itemLabel(item)),
                  onDeleted: () {
                    final List<T> newList = List<T>.from(syncedSelectedItems)..remove(item);
                    onChanged(newList);
                  },
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: DropdownButtonFormField<T>(
                key: ValueKey<String>('dropdown_$itemsKey'),
                decoration: InputDecoration(
                  labelText: 'Add $label',
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
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                items: availableItems.isEmpty
                    ? <DropdownMenuItem<T>>[]
                    : availableItems.map((T item) {
                        return DropdownMenuItem<T>(
                          value: item,
                          child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
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
