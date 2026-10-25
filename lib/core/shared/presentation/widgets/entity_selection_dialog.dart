import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'custom_icons.dart';

/// A reusable dialog for selecting single or multiple entities (e.g. Books, Works).
///
/// For multi-select: displays a searchable list with checkboxes, Select All / Clear,
/// and Cancel / OK buttons.
///
/// For single-select: displays a searchable list where tapping an item immediately
/// selects it and closes the dialog.
class EntitySelectionDialog<T> extends StatefulWidget {
  const EntitySelectionDialog({
    super.key,
    required this.title,
    required this.items,
    required this.itemLabel,
    this.itemSubtitle,
    this.itemKey,
    this.initialSelected = const <Never>[],
    this.isMultiSelect = true,
    this.searchHint = 'Search...',
    this.icon,
  });

  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final String Function(T)? itemSubtitle;
  final Object Function(T)? itemKey;
  final List<T> initialSelected;
  final bool isMultiSelect;
  final String searchHint;
  final dynamic icon;

  static Future<List<T>?> showMulti<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    String Function(T)? itemSubtitle,
    Object Function(T)? itemKey,
    List<T> initialSelected = const <Never>[],
    dynamic icon,
    int Function(T, T)? sortComparator,
  }) async {
    final List<T> sortedItems = List<T>.from(items);
    if (sortComparator != null) {
      sortedItems.sort(sortComparator);
    }
    return showDialog<List<T>>(
      context: context,
      builder: (BuildContext ctx) => EntitySelectionDialog<T>(
        title: title,
        items: sortedItems,
        itemLabel: itemLabel,
        itemSubtitle: itemSubtitle,
        itemKey: itemKey,
        initialSelected: initialSelected,
        icon: icon,
      ),
    );
  }

  static Future<T?> showSingle<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    String Function(T)? itemSubtitle,
    Object Function(T)? itemKey,
    dynamic icon,
    int Function(T, T)? sortComparator,
  }) async {
    final List<T> sortedItems = List<T>.from(items);
    if (sortComparator != null) {
      sortedItems.sort(sortComparator);
    }
    final List<T>? result = await showDialog<List<T>>(
      context: context,
      builder: (BuildContext ctx) => EntitySelectionDialog<T>(
        title: title,
        items: sortedItems,
        itemLabel: itemLabel,
        itemSubtitle: itemSubtitle,
        itemKey: itemKey,
        isMultiSelect: false,
        icon: icon,
      ),
    );
    return (result != null && result.isNotEmpty) ? result.first : null;
  }

  @override
  State<EntitySelectionDialog<T>> createState() => _EntitySelectionDialogState<T>();
}

class _EntitySelectionDialogState<T> extends State<EntitySelectionDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  late final List<T> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _areEqual(T a, T b) {
    if (widget.itemKey != null) {
      return widget.itemKey!(a) == widget.itemKey!(b);
    }
    return a == b;
  }

  bool _isSelected(T item) => _selected.any((T e) => _areEqual(e, item));

  void _toggle(T item) {
    setState(() {
      if (_isSelected(item)) {
        _selected.removeWhere((T e) => _areEqual(e, item));
      } else {
        _selected.add(item);
      }
    });
  }

  List<T> get _filteredItems {
    if (_searchQuery.trim().isEmpty) {
      return widget.items;
    }
    final String query = _searchQuery.trim().toLowerCase();
    return widget.items.where((T item) {
      final String label = widget.itemLabel(item).toLowerCase();
      if (label.contains(query)) {
        return true;
      }
      if (widget.itemSubtitle != null) {
        final String subtitle = widget.itemSubtitle!(item).toLowerCase();
        if (subtitle.contains(query)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<T> filtered = _filteredItems;
    final double maxDialogHeight = MediaQuery.sizeOf(context).height * 0.72;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxDialogHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header
              Row(
                children: <Widget>[
                  if (widget.icon != null) ...<Widget>[
                    buildAppIcon(widget.icon, color: colorScheme.primary, size: 22) ?? const SizedBox.shrink(),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (String val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 10),

              // Multi-select info bar
              if (widget.isMultiSelect)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${_selected.length} of ${widget.items.length} selected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            final bool allSelected = filtered.every(_isSelected);
                            if (allSelected) {
                              for (final T item in filtered) {
                                _selected.removeWhere((T e) => _areEqual(e, item));
                              }
                            } else {
                              for (final T item in filtered) {
                                if (!_isSelected(item)) {
                                  _selected.add(item);
                                }
                              }
                            }
                          });
                        },
                        child: Text(
                          filtered.every(_isSelected) && filtered.isNotEmpty
                              ? 'Deselect All'
                              : 'Select All',
                          style: TextStyle(fontSize: 13, color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              // Items List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            widget.items.isEmpty
                                ? 'No items available.'
                                : 'No matching items found.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (BuildContext context, int index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final T item = filtered[index];
                            final String title = widget.itemLabel(item);
                            final String? subtitle = widget.itemSubtitle?.call(item);

                            if (widget.isMultiSelect) {
                              final bool isSelected = _isSelected(item);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) => _toggle(item),
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                subtitle: (subtitle != null && subtitle.isNotEmpty)
                                    ? Text(
                                        subtitle,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      )
                                    : null,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                dense: true,
                              );
                            } else {
                              return ListTile(
                                title: Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: (subtitle != null && subtitle.isNotEmpty)
                                    ? Text(
                                        subtitle,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      )
                                    : null,
                                trailing: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                dense: true,
                                onTap: () => Navigator.of(context).pop(<T>[item]),
                              );
                            }
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  if (widget.isMultiSelect) ...<Widget>[
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      child: const Text('OK'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
