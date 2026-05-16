import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import 'form_decoration.dart';

class SearchMultiPickerField<T> extends ConsumerStatefulWidget {
  const SearchMultiPickerField({
    super.key,
    required this.label,
    required this.selectedItems,
    required this.itemsProvider,
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
    this.onAdd,
    this.itemKey,
    this.chipLabel,
    this.onChipPressed,
    this.onBeforeAdd,
  });

  final String label;
  final List<T> selectedItems;
  final Refreshable<AsyncValue<List<T>>> itemsProvider;
  final String Function(T) itemLabel;
  final ValueChanged<List<T>> onChanged;
  final IconData? prefixIcon;
  final Future<T?> Function()? onAdd;
  final Object Function(T)? itemKey;
  final String Function(T)? chipLabel;
  final void Function(T)? onChipPressed;
  final Future<bool> Function(T)? onBeforeAdd;

  @override
  ConsumerState<SearchMultiPickerField<T>> createState() => _SearchMultiPickerFieldState<T>();
}

class _SearchMultiPickerFieldState<T> extends ConsumerState<SearchMultiPickerField<T>> {
  bool _areEqual(T a, T b) {
    if (widget.itemKey != null) {
      return widget.itemKey!(a) == widget.itemKey!(b);
    }
    return a == b;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: () => _showPicker(context),
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
            decoration: buildFormDecoration(
              colorScheme,
              labelText: widget.label,
              prefixIcon: widget.prefixIcon,
            ),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text('Add Items...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (widget.selectedItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          InputDecorator(
            decoration: buildFormDecoration(colorScheme, contentPadding: const EdgeInsets.all(8)),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.selectedItems
                  .map(
                    (T item) => InputChip(
                      label: Text((widget.chipLabel ?? widget.itemLabel)(item)),
                      onDeleted: () {
                        final List<T> newList = List<T>.from(widget.selectedItems)
                          ..removeWhere((T e) => _areEqual(e, item));
                        widget.onChanged(newList);
                      },
                      onPressed: widget.onChipPressed != null
                          ? () => widget.onChipPressed!(item)
                          : null,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  void _showPicker(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) => _MultiPickerSheet<T>(
        label: widget.label,
        itemsProvider: widget.itemsProvider,
        itemLabel: widget.itemLabel,
        selectedItems: widget.selectedItems,
        itemKey: widget.itemKey,
        onChanged: widget.onChanged,
        onAdd: widget.onAdd,
        onBeforeAdd: widget.onBeforeAdd,
      ),
    );
  }
}

class _MultiPickerSheet<T> extends ConsumerStatefulWidget {
  const _MultiPickerSheet({
    required this.label,
    required this.itemsProvider,
    required this.itemLabel,
    required this.selectedItems,
    required this.onChanged,
    this.onAdd,
    this.itemKey,
    this.onBeforeAdd,
  });

  final String label;
  final Refreshable<AsyncValue<List<T>>> itemsProvider;
  final String Function(T) itemLabel;
  final List<T> selectedItems;
  final ValueChanged<List<T>> onChanged;
  final Future<T?> Function()? onAdd;
  final Object Function(T)? itemKey;
  final Future<bool> Function(T)? onBeforeAdd;

  @override
  ConsumerState<_MultiPickerSheet<T>> createState() => _MultiPickerSheetState<T>();
}

class _MultiPickerSheetState<T> extends ConsumerState<_MultiPickerSheet<T>> {
  @override
  void initState() {
    super.initState();
    _currentSelections = List<T>.from(widget.selectedItems);
  }

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late List<T> _currentSelections;

  bool _areEqual(T a, T b) {
    if (widget.itemKey != null) {
      return widget.itemKey!(a) == widget.itemKey!(b);
    }
    return a == b;
  }

  bool _isItemLocallySelected(T item) => _currentSelections.any((T e) => _areEqual(e, item));

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<T>> itemsAsync = ref.watch(widget.itemsProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: <Widget>[
                Text('Select ${widget.label}', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (widget.onAdd != null)
                  IconButton.filledTonal(
                    onPressed: () async {
                      final T? newItem = await widget.onAdd!();
                      if (newItem != null) {
                        setState(() {
                          _currentSelections.add(newItem);
                        });
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (String val) => setState(() => _query = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: itemsAsync.when(
              data: (List<T> items) {
                final List<T> sortedItems = items.toList()
                  ..sort((T a, T b) => widget.itemLabel(a).compareTo(widget.itemLabel(b)));

                final List<T> filtered = sortedItems
                    .where((T e) => widget.itemLabel(e).toLowerCase().contains(_query))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (BuildContext context, int index) {
                    final T item = filtered[index];
                    final bool isSelected = _isItemLocallySelected(item);
                    return CheckboxListTile(
                      title: Text(widget.itemLabel(item)),
                      value: isSelected,
                      onChanged: (bool? val) async {
                        if (val ?? false) {
                          if (widget.onBeforeAdd != null) {
                            final bool proceed = await widget.onBeforeAdd!(item);
                            if (!proceed) {
                              return;
                            }
                          }
                          setState(() {
                            _currentSelections.add(item);
                          });
                        } else {
                          setState(() {
                            _currentSelections.removeWhere((T e) => _areEqual(e, item));
                          });
                        }
                      },
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(strokeWidth: 3, color: colorScheme.primary),
              ),
              error: (Object e, StackTrace s) => Center(
                child: Text(
                  'Error: $e',
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                widget.onChanged(_currentSelections);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Done (${_currentSelections.length} Selected)'),
            ),
          ),
        ],
      ),
    );
  }
}
