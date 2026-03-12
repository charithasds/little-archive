import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

/// A reusable date picker field that matches the app's design system.
///
/// Displays the selected date or a placeholder title. Supports an optional
/// clear button via [isClearable]. Uses [showDatePicker] to select a date.
class FormDateField extends ConsumerWidget {
  const FormDateField({
    super.key,
    required this.label,
    required this.onDateSelected,
    this.value,
    this.icon = Icons.calendar_today_rounded,
    this.isClearable = false,
    this.onCleared,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final IconData icon;
  final void Function(DateTime) onDateSelected;
  final bool isClearable;
  final VoidCallback? onCleared;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1000),
      lastDate: lastDate ?? DateTime(3000),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeProvider);
    final ThemeData theme = themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(value == null ? label : '$label: ${DateFormat.yMMMd().format(value!)}'),
        subtitle: value == null ? const Text('Tap to select') : null,
        trailing: isClearable && value != null
            ? IconButton(icon: const Icon(Icons.clear), onPressed: onCleared)
            : null,
        onTap: () => _selectDate(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
