import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import 'form_decoration.dart';

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
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: buildFormDecoration(colorScheme, labelText: label, prefixIcon: icon),
        isEmpty: value == null,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                value == null ? 'Select Date' : DateFormat.yMMMd().format(value!),
                style: TextStyle(
                  color: value == null ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            if (isClearable && value != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.clear, size: 20),
                onPressed: onCleared,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
