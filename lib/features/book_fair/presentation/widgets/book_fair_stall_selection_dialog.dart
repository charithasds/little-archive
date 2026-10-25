import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/services/book_fair_sheets_service.dart';

class BookFairStallSelectionDialog extends StatefulWidget {
  const BookFairStallSelectionDialog({super.key, required this.entries});

  final List<BookFairExportEntry> entries;

  static Future<List<BookFairExportEntry>?> show(
    BuildContext context,
    List<BookFairExportEntry> entries,
  ) => showDialog<List<BookFairExportEntry>>(
    context: context,
    builder: (BuildContext ctx) => BookFairStallSelectionDialog(entries: entries),
  );

  @override
  State<BookFairStallSelectionDialog> createState() => _BookFairStallSelectionDialogState();
}

class _BookFairStallSelectionDialogState extends State<BookFairStallSelectionDialog> {
  final Set<String> _selectedStalls = <String>{};
  late final List<String> _allStalls;

  @override
  void initState() {
    super.initState();

    // Extract unique stalls (handling empty stalls as "Unknown Stall")
    final Set<String> uniqueStalls = <String>{};
    for (final BookFairExportEntry entry in widget.entries) {
      final String stallKey = entry.stallName.trim().isEmpty && entry.stallNo.trim().isEmpty
          ? 'Unknown Stall'
          : '${entry.stallNo} ${entry.stallName}'.trim();
      uniqueStalls.add(stallKey);
    }

    _allStalls = uniqueStalls.toList()..sort();
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedStalls.addAll(_allStalls);
      } else {
        _selectedStalls.clear();
      }
    });
  }

  void _submit() {
    final List<BookFairExportEntry> filtered = widget.entries.where((BookFairExportEntry entry) {
      final String stallKey = entry.stallName.trim().isEmpty && entry.stallNo.trim().isEmpty
          ? 'Unknown Stall'
          : '${entry.stallNo} ${entry.stallName}'.trim();
      return _selectedStalls.contains(stallKey);
    }).toList();

    Navigator.of(context).pop(filtered);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);

    final bool isAllSelected = _selectedStalls.length == _allStalls.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                FaIcon(FontAwesomeIcons.store, color: purplePrimary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select Stalls',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Choose which stalls to include in the exported shopping list.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // Select All Toggle
            CheckboxListTile(
              value: isAllSelected,
              onChanged: _toggleSelectAll,
              title: const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
              activeColor: purplePrimary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Divider(),

            // Stalls List
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allStalls.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String stall = _allStalls[index];
                    final bool isSelected = _selectedStalls.contains(stall);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedStalls.add(stall);
                          } else {
                            _selectedStalls.remove(stall);
                          }
                        });
                      },
                      title: Text(stall, style: theme.textTheme.bodyMedium),
                      activeColor: purplePrimary,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purplePrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _selectedStalls.isEmpty ? null : _submit,
                  child: const Text('Export', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
