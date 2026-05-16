import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import 'form_decoration.dart';

class SearchPickerField<T> extends ConsumerStatefulWidget {
  const SearchPickerField({
    super.key,
    required this.label,
    required this.selectedItem,
    required this.itemsProvider,
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
    this.onAdd,
    this.isNullable = true,
    this.itemKey,
    this.filterItems,
  });

  final String label;
  final T? selectedItem;
  final Refreshable<AsyncValue<List<T>>> itemsProvider;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final Future<T?> Function()? onAdd;
  final bool isNullable;
  final Object Function(T)? itemKey;
  final List<T> Function(List<T>)? filterItems;

  @override
  ConsumerState<SearchPickerField<T>> createState() => _SearchPickerFieldState<T>();
}

class _SearchPickerFieldState<T> extends ConsumerState<SearchPickerField<T>> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
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
            Expanded(
              child: Text(
                widget.selectedItem != null
                    ? widget.itemLabel(widget.selectedItem as T)
                    : 'Select ${widget.label}',
                style: TextStyle(
                  color: widget.selectedItem != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
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
      builder: (BuildContext context) => _PickerSheet<T>(
        label: widget.label,
        itemsProvider: widget.itemsProvider,
        itemLabel: widget.itemLabel,
        onSelected: (T? val) {
          widget.onChanged(val);
          Navigator.pop(context);
        },
        onAdd: widget.onAdd,
        isNullable: widget.isNullable,
        filterItems: widget.filterItems,
      ),
    );
  }
}

class _PickerSheet<T> extends ConsumerStatefulWidget {
  const _PickerSheet({
    required this.label,
    required this.itemsProvider,
    required this.itemLabel,
    required this.onSelected,
    this.onAdd,
    required this.isNullable,
    this.filterItems,
  });

  final String label;
  final Refreshable<AsyncValue<List<T>>> itemsProvider;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onSelected;
  final Future<T?> Function()? onAdd;
  final bool isNullable;
  final List<T> Function(List<T>)? filterItems;

  @override
  ConsumerState<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends ConsumerState<_PickerSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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
                        widget.onSelected(newItem);
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
                final List<T> preFiltered = widget.filterItems != null
                    ? widget.filterItems!(items)
                    : items;
                final List<T> sortedItems = preFiltered.toList()
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
                  itemCount: filtered.length + (widget.isNullable ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (widget.isNullable && index == 0) {
                      return ListTile(
                        title: const Text('None'),
                        onTap: () => widget.onSelected(null),
                      );
                    }
                    final T item = filtered[index - (widget.isNullable ? 1 : 0)];
                    return ListTile(
                      title: Text(widget.itemLabel(item)),
                      onTap: () => widget.onSelected(item),
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
        ],
      ),
    );
  }
}
