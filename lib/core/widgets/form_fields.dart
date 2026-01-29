import 'package:flutter/material.dart';

class SingleSelectField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String label;
  final VoidCallback? onAdd;
  final bool isNullable;

  const SingleSelectField({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.label,
    this.onAdd,
    this.isNullable = true,
  });

  @override
  Widget build(BuildContext context) {
    // Find the matching item from the current items list
    // This handles cases where Equatable compares by id only
    final effectiveValue = value != null && items.contains(value)
        ? value
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: DropdownButtonFormField<T>(
            // Use a key based on items to force rebuild when list changes
            key: ValueKey(items.map((i) => i.hashCode).join(',')),
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            items: [
              if (isNullable)
                const DropdownMenuItem(value: null, child: Text('None')),
              ...items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                );
              }),
            ],
            initialValue: effectiveValue,
            onChanged: onChanged,
            validator: (val) {
              if (!isNullable && val == null) return 'Required';
              return null;
            },
          ),
        ),
        if (onAdd != null) ...[
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
  final List<T> selectedItems;
  final List<T> allItems;
  final String Function(T) itemLabel;
  final void Function(List<T>) onChanged;
  final String label;
  final VoidCallback? onAdd;

  const MultiSelectField({
    super.key,
    required this.selectedItems,
    required this.allItems,
    required this.itemLabel,
    required this.onChanged,
    required this.label,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // Sync selected items with allItems to use the fresh object references
    // This is important because Equatable compares by id, but we need
    // the exact object reference from allItems for the dropdown to work
    final syncedSelectedItems = <T>[];
    for (final selected in selectedItems) {
      // Find matching item in allItems (uses Equatable == which compares by id)
      final match = allItems.where((item) => item == selected);
      if (match.isNotEmpty) {
        syncedSelectedItems.add(match.first);
      }
    }

    // Filter out already selected items for the dropdown
    final availableItems = allItems
        .where((item) => !syncedSelectedItems.contains(item))
        .toList();

    // Generate a key based on availableItems to force rebuild when selection changes
    final itemsKey = availableItems.map((i) => i.hashCode).join(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(8),
          ),
          child: Wrap(
            spacing: 8.0,
            children: [
              if (syncedSelectedItems.isEmpty)
                const Text(
                  'No items selected',
                  style: TextStyle(color: Colors.grey),
                ),
              ...syncedSelectedItems.map((item) {
                return Chip(
                  label: Text(itemLabel(item)),
                  onDeleted: () {
                    final newList = List<T>.from(syncedSelectedItems)
                      ..remove(item);
                    onChanged(newList);
                  },
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<T>(
                key: ValueKey('dropdown_$itemsKey'),
                initialValue:
                    null, // Always reset to null to prevent assertion errors
                decoration: InputDecoration(
                  labelText: 'Add $label',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                ),
                items: availableItems.isEmpty
                    ? []
                    : availableItems.map((item) {
                        return DropdownMenuItem<T>(
                          value: item,
                          child: Text(
                            itemLabel(item),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                onChanged: (T? value) {
                  if (value != null) {
                    final newList = List<T>.from(syncedSelectedItems)
                      ..add(value);
                    onChanged(newList);
                  }
                },
              ),
            ),
            if (onAdd != null) ...[
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
