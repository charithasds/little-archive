import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFmt = DateFormat('d MMM yyyy');

class StatusDateField extends StatelessWidget {
  const StatusDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.errorText,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final ThemeData theme;
  final String? errorText;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        onChanged(picked);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: errorText,
      ),
      child: Text(_dateFmt.format(value), style: theme.textTheme.bodyMedium),
    ),
  );
}
